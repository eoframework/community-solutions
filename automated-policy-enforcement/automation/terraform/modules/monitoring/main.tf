#------------------------------------------------------------------------------
# Tier 2: Monitoring — CloudWatch dashboards, SNS alerting topic
# Three operational dashboards: platform ops, identity/access, DR replication
#------------------------------------------------------------------------------

resource "aws_sns_topic" "platform_alerts" {
  name              = "${var.name_prefix}-platform-alerts"
  kms_master_key_id = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-platform-alerts"
    Purpose = "platform-alerting"
  })
}

resource "aws_cloudwatch_dashboard" "platform_ops" {
  dashboard_name = var.dashboard_platform_ops

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          title  = "AFT Pipeline Executions"
          view   = "timeSeries"
          metrics = [
            ["AWS/CodePipeline", "SucceededPipelineExecutions", "PipelineName", "${var.aft_pipeline_name}"],
            ["AWS/CodePipeline", "FailedPipelineExecutions", "PipelineName", "${var.aft_pipeline_name}"]
          ]
          period = 300
          stat   = "Sum"
          region = "ap-southeast-2"
        }
      },
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          title  = "SIEM DLQ Depth"
          view   = "timeSeries"
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "${var.dlq_name}"]
          ]
          period = 300
          stat   = "Sum"
          region = "ap-southeast-2"
        }
      },
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          title  = "Config Rule Evaluation Count"
          view   = "timeSeries"
          metrics = [
            ["AWS/Config", "ConfigRuleEvaluations"]
          ]
          period = 300
          stat   = "Sum"
          region = "ap-southeast-2"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "identity_access" {
  dashboard_name = var.dashboard_identity

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 24
        height = 6
        properties = {
          title  = "IAM Identity Center Login Events"
          view   = "timeSeries"
          metrics = [
            ["AWS/SSO", "UserAuthentications"]
          ]
          period = 300
          stat   = "Sum"
          region = "ap-southeast-2"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "dr_replication" {
  dashboard_name = var.dashboard_dr

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 24
        height = 6
        properties = {
          title  = "S3 CRR Replication Latency (ap-southeast-4)"
          view   = "timeSeries"
          metrics = [
            ["AWS/S3", "ReplicationLatency"]
          ]
          period = 300
          stat   = "Maximum"
          region = "ap-southeast-2"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "platform" {
  name              = "/aws/${var.name_prefix}/platform"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-platform-logs"
    Purpose = "platform-observability"
  })
}
