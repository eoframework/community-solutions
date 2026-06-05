#------------------------------------------------------------------------------
# Monitoring Module - Tier 2 Solution Module
# Composes SNS, CloudWatch dashboard, and CloudTrail
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# SNS Topic for Operational Alerts
#------------------------------------------------------------------------------
module "sns_ops_alerts" {
  source = "../aws/sns"

  topic_name          = "${var.name_prefix}-sns-ops-alerts"
  email_subscriptions = var.monitoring.alert_email_subscriptions

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# CloudTrail
#------------------------------------------------------------------------------
module "cloudtrail" {
  source = "../aws/cloudtrail"

  name_prefix                = var.name_prefix
  cloudtrail_bucket_name     = var.monitoring.cloudtrail_bucket_name
  retention_days             = var.monitoring.cloudtrail_retention_days
  cloudwatch_retention_days  = var.monitoring.cloudtrail_retention_days
  s3_data_events_bucket_arn  = var.s3_data_events_enabled ? var.artifact_bucket_arn : ""

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# CloudWatch Dashboard
#------------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.monitoring.cloudwatch_dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "metric"
        x          = 0
        y          = 0
        width      = 12
        height     = 6
        properties = {
          title   = "Lambda Error Rates"
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", "${var.name_prefix}-fn-api-handler"],
            ["AWS/Lambda", "Errors", "FunctionName", "${var.name_prefix}-fn-generation-initiator"],
            ["AWS/Lambda", "Errors", "FunctionName", "${var.name_prefix}-fn-github-push"]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
        }
      },
      {
        type       = "metric"
        x          = 12
        y          = 0
        width      = 12
        height     = 6
        properties = {
          title   = "Lambda Duration P99"
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", "${var.name_prefix}-fn-api-handler"],
            ["AWS/Lambda", "Duration", "FunctionName", "${var.name_prefix}-fn-agent-eo-validator"]
          ]
          period = 300
          stat   = "p99"
          region = var.region
        }
      },
      {
        type       = "metric"
        x          = 0
        y          = 6
        width      = 12
        height     = 6
        properties = {
          title   = "DynamoDB Consumed Capacity"
          metrics = [
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", var.solutions_table_name],
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits",  "TableName", var.quotas_table_name]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
        }
      },
      {
        type       = "metric"
        x          = 12
        y          = 6
        width      = 12
        height     = 6
        properties = {
          title   = "API Gateway Latency P99"
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiId", var.api_gateway_id]
          ]
          period = 300
          stat   = "p99"
          region = var.region
        }
      }
    ]
  })
}

#------------------------------------------------------------------------------
# CloudWatch Alarms
#------------------------------------------------------------------------------

# Lambda High Error Rate
resource "aws_cloudwatch_metric_alarm" "lambda_error_rate" {
  alarm_name          = "${var.name_prefix}-alarm-lambda-error-rate"
  alarm_description   = "Lambda error rate exceeds threshold — P2 alert"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = var.monitoring.alarm_lambda_error_rate_pct
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.sns_ops_alerts.topic_arn]
  ok_actions    = [module.sns_ops_alerts.topic_arn]

  tags = var.common_tags
}

# Bedrock Throttle
resource "aws_cloudwatch_metric_alarm" "bedrock_throttle" {
  alarm_name          = "${var.name_prefix}-alarm-bedrock-throttle"
  alarm_description   = "Bedrock ThrottlingException count exceeds threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/Bedrock"
  period              = 300
  statistic           = "Sum"
  threshold           = var.monitoring.alarm_bedrock_throttle_count
  treat_missing_data  = "notBreaching"

  alarm_actions = [module.sns_ops_alerts.topic_arn]

  tags = var.common_tags
}

# GitHub DLQ Depth
resource "aws_cloudwatch_metric_alarm" "github_dlq_depth" {
  alarm_name          = "${var.name_prefix}-alarm-github-dlq-depth"
  alarm_description   = "GitHub push DLQ has messages — investigate failed commits"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = var.github_dlq_name
  }

  alarm_actions = [module.sns_ops_alerts.topic_arn]

  tags = var.common_tags
}

# API Gateway P99 Latency
resource "aws_cloudwatch_metric_alarm" "apigw_latency_p99" {
  alarm_name          = "${var.name_prefix}-alarm-apigw-p99-latency"
  alarm_description   = "API Gateway P99 latency exceeds SLA target"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = 300
  extended_statistic  = "p99"
  threshold           = var.monitoring.api_gateway_p99_latency_ms
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiId = var.api_gateway_id
  }

  alarm_actions = [module.sns_ops_alerts.topic_arn]

  tags = var.common_tags
}
