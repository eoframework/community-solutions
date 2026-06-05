#------------------------------------------------------------------------------
# Tier 2: Monitoring — CloudWatch dashboards, SNS topic, log groups, alarms
# Composes aws/cloudwatch resources for the Amatra platform observability stack
# Custom metrics: AmatraPlatform/TokenUsage, GenerationLatencyMs, ValidationRetryRate
#------------------------------------------------------------------------------

# SNS topic for operational alerts — routes to Amatra ops and PREDICTif contact
resource "aws_sns_topic" "alarms" {
  name              = "${var.name_prefix}-alarms"
  kms_master_key_id = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alarms"
  })
}

# CloudWatch Log Groups — structured JSON logs with correlation IDs per solution_id
resource "aws_cloudwatch_log_group" "platform" {
  name              = "/amatra/${var.environment}/platform"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name = "/amatra/${var.environment}/platform"
  })
}

# CloudWatch Dashboard — single pane of glass for platform health
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.cloudwatch_dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Errors"
          view   = "timeSeries"
          region = "us-west-2"
          metrics = [
            ["AWS/Lambda", "Errors", { stat = "Sum", period = 300 }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Step Functions Execution Failures"
          view   = "timeSeries"
          region = "us-west-2"
          metrics = [
            ["AWS/States", "ExecutionsFailed", { stat = "Sum", period = 300 }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Bedrock Token Usage"
          view   = "timeSeries"
          region = "us-west-2"
          metrics = [
            [var.metrics_namespace, var.token_usage_metric_name, { stat = "Sum", period = 3600 }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Solution Generation Latency"
          view   = "timeSeries"
          region = "us-west-2"
          metrics = [
            [var.metrics_namespace, "GenerationLatencyMs", { stat = "p95", period = 3600 }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "DynamoDB Conditional Write Failures"
          view   = "timeSeries"
          region = "us-west-2"
          metrics = [
            ["AWS/DynamoDB", "ConditionalCheckFailedRequests", "TableName", var.table_quota_global_name, { stat = "Sum", period = 300 }]
          ]
        }
      }
    ]
  })
}

# DLQ depth alarm — CRITICAL severity per SOW alert definition
resource "aws_cloudwatch_metric_alarm" "dlq_depth" {
  alarm_name          = "${var.name_prefix}-dlq-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "CRITICAL: DLQ received a message — agent pipeline failure requires immediate triage"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  treat_missing_data  = "notBreaching"

  tags = var.common_tags
}

# Bedrock token spend alarm per SOW — 110% of daily budget
resource "aws_cloudwatch_metric_alarm" "bedrock_token_spend" {
  alarm_name          = "${var.name_prefix}-bedrock-token-spend"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = var.token_usage_metric_name
  namespace           = var.metrics_namespace
  period              = 86400
  statistic           = "Sum"
  threshold           = (var.monthly_token_budget_millions * 1000000 / 30) * (var.bedrock_daily_spend_alarm_pct / 100)
  alarm_description   = "Daily Bedrock token spend exceeded ${var.bedrock_daily_spend_alarm_pct}% of daily budget — check for runaway retry loops"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  treat_missing_data  = "notBreaching"

  tags = var.common_tags
}
