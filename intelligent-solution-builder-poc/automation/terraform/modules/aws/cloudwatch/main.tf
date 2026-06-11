###############################################################################
# Tier 1 Provider Module — AWS CloudWatch
# Creates SNS topic, CloudWatch dashboard, and alarm set for the ISB platform.
###############################################################################

#--------------------------------------
# SNS Topic for Alarm Notifications
#--------------------------------------
resource "aws_sns_topic" "alerts" {
  name              = "${var.name_prefix}-alerts"
  kms_master_key_id = var.kms_key_id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alerts"
  })
}

#--------------------------------------
# CloudWatch Dashboard
#--------------------------------------
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.dashboard_name
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "API Gateway - Request Rate & Error Rate"
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_name],
            ["AWS/ApiGateway", "5XXError", "ApiName", var.api_name],
            ["AWS/ApiGateway", "4XXError", "ApiName", var.api_name]
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
          title  = "API Gateway - P95 Latency"
          period = 60
          stat   = "p95"
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiName", var.api_name]
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
          title  = "Step Functions - Executions"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/States", "ExecutionsStarted", "StateMachineArn", var.step_functions_arn],
            ["AWS/States", "ExecutionsSucceeded", "StateMachineArn", var.step_functions_arn],
            ["AWS/States", "ExecutionsFailed", "StateMachineArn", var.step_functions_arn]
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
          title  = "SQS - Queue Depth & DLQ"
          period = 60
          stat   = "Maximum"
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.generation_queue_name],
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.dlq_name]
          ]
        }
      }
    ]
  })
}
