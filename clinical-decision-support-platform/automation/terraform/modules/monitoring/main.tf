################################################################################
# Tier 2 — Monitoring Module
# CloudWatch dashboards, SNS alarm topic, X-Ray, and CloudWatch Alarms.
################################################################################

resource "aws_sns_topic" "alarms" {
  name              = "${var.name_prefix}-alarms"
  kms_master_key_id = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alarms"
  })
}

resource "aws_sns_topic_subscription" "pagerduty" {
  count     = var.monitoring.pagerduty_endpoint != null ? 1 : 0
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "https"
  endpoint  = var.monitoring.pagerduty_endpoint
}

# ---------------------------------------------------------------------------
# CloudWatch Dashboard — Ingestion Pipeline
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "ingestion" {
  dashboard_name = "${var.name_prefix}-ingestion"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "Kinesis Stream — Incoming Records"
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/Kinesis", "IncomingRecords", "StreamName", var.monitoring.kinesis_stream_name]
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "Kinesis — Iterator Age (ms)"
          period = 60
          stat   = "Maximum"
          metrics = [
            ["AWS/Kinesis", "GetRecords.IteratorAgeMilliseconds", "StreamName", var.monitoring.kinesis_stream_name]
          ]
        }
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# CloudWatch Dashboard — ML Inference
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "ml_inference" {
  dashboard_name = "${var.name_prefix}-ml-inference"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "SageMaker Endpoint — Invocations"
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/SageMaker", "Invocations", "EndpointName", "${var.name_prefix}-sepsis-ep", "VariantName", "AllTraffic"]
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "SageMaker Endpoint — P95 Latency (ms)"
          period = 60
          stat   = "p95"
          metrics = [
            ["AWS/SageMaker", "ModelLatency", "EndpointName", "${var.name_prefix}-sepsis-ep", "VariantName", "AllTraffic"]
          ]
        }
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# CloudWatch Dashboard — Application (ECS / ALB)
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "application" {
  dashboard_name = var.monitoring.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "ECS Cluster — CPU Utilization"
          period = 60
          stat   = "Average"
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.monitoring.ecs_cluster_name, "ServiceName", "dashboard"]
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "ALB — 5xx Errors"
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count"]
          ]
        }
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# CloudWatch Dashboard — Compliance
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "compliance" {
  dashboard_name = "${var.name_prefix}-compliance"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "AWS Config — Non-Compliant Resources"
          period = 3600
          stat   = "Sum"
          metrics = [
            ["AWS/Config", "NonCompliantRuleCount"]
          ]
        }
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# Inference Latency Alarm — Critical (> 3000ms P95)
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "inference_latency" {
  alarm_name          = "${var.name_prefix}-inference-latency-p95"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ModelLatency"
  namespace           = "AWS/SageMaker"
  period              = 60
  extended_statistic  = "p95"
  threshold           = var.monitoring.latency_alarm_threshold_ms
  alarm_description   = "CRITICAL: SageMaker P95 latency > ${var.monitoring.latency_alarm_threshold_ms}ms — risk of clinical SLA breach"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    EndpointName = "${var.name_prefix}-sepsis-ep"
    VariantName  = "AllTraffic"
  }

  tags = var.common_tags
}

# ---------------------------------------------------------------------------
# ECS CPU Alarm — High (> 80%)
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  alarm_name          = "${var.name_prefix}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.monitoring.ecs_cpu_alarm_threshold_pct
  alarm_description   = "HIGH: ECS Fargate CPU > ${var.monitoring.ecs_cpu_alarm_threshold_pct}% — investigate scale-out"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.monitoring.ecs_cluster_name
  }

  tags = var.common_tags
}

# ---------------------------------------------------------------------------
# AWS Config — HIPAA continuous compliance monitoring
# ---------------------------------------------------------------------------
resource "aws_config_configuration_recorder" "this" {
  count = var.monitoring.enable_config ? 1 : 0
  name  = "${var.name_prefix}-config-recorder"

  role_arn = aws_iam_role.config[0].arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_iam_role" "config" {
  count = var.monitoring.enable_config ? 1 : 0
  name  = "${var.name_prefix}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "config" {
  count      = var.monitoring.enable_config ? 1 : 0
  role       = aws_iam_role.config[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_delivery_channel" "this" {
  count          = var.monitoring.enable_config ? 1 : 0
  name           = "${var.name_prefix}-config-delivery"
  s3_bucket_name = var.audit_bucket_id

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  count      = var.monitoring.enable_config ? 1 : 0
  name       = aws_config_configuration_recorder.this[0].name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}
