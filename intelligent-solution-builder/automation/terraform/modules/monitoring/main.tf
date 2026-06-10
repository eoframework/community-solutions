#------------------------------------------------------------------------------
# Tier 2 — Monitoring Module
# CloudWatch Dashboards, SNS alerts topic, and CloudWatch Synthetics canary
# SOC 2 A1 / PI1 — availability and processing integrity observability
#------------------------------------------------------------------------------

# SNS topic for operational alerts (P1→PagerDuty, P2→Slack, P3→email)
resource "aws_sns_topic" "alerts" {
  name = "${var.name_prefix}-alerts"
  tags = var.common_tags
}

# CloudWatch Operations Dashboard
resource "aws_cloudwatch_dashboard" "operations" {
  dashboard_name = var.operations_dashboard_name
  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "metric"
        properties = {
          title  = "SQS Job Queue Depth"
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "${var.name_prefix}-job-queue"]
          ]
        }
      },
      {
        type       = "metric"
        properties = {
          title  = "Step Functions Execution Success Rate"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/States", "ExecutionsSucceeded", "StateMachineArn", var.state_machine_arn],
            ["AWS/States", "ExecutionsFailed", "StateMachineArn", var.state_machine_arn]
          ]
        }
      },
      {
        type       = "metric"
        properties = {
          title  = "API Gateway 5xx Error Rate"
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/ApiGateway", "5XXError", "ApiName", "${var.name_prefix}-api", "Stage", var.api_stage_name]
          ]
        }
      },
      {
        type       = "metric"
        properties = {
          title  = "Lambda Error Rates"
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", "isb-api-submit-${var.environment}"],
            ["AWS/Lambda", "Errors", "FunctionName", "isb-bedrock-sonnet-${var.environment}"],
            ["AWS/Lambda", "Errors", "FunctionName", "isb-bedrock-haiku-${var.environment}"]
          ]
        }
      }
    ]
  })
}

# CloudWatch SLA Dashboard
resource "aws_cloudwatch_dashboard" "sla" {
  dashboard_name = var.sla_dashboard_name
  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "metric"
        properties = {
          title  = "Platform Availability (API Health)"
          period = 300
          stat   = "Average"
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", "${var.name_prefix}-api", "Stage", var.api_stage_name]
          ]
        }
      },
      {
        type       = "metric"
        properties = {
          title  = "Step Functions Execution Duration p95"
          period = 3600
          stat   = "p95"
          metrics = [
            ["AWS/States", "ExecutionTime", "StateMachineArn", var.state_machine_arn]
          ]
        }
      }
    ]
  })
}

# CloudWatch Quality & Usage Dashboard
resource "aws_cloudwatch_dashboard" "quality" {
  dashboard_name = var.quality_dashboard_name
  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "metric"
        properties = {
          title  = "Bedrock Invocation Count"
          period = 3600
          stat   = "Sum"
          metrics = [
            ["AWS/Bedrock", "Invocations", "ModelId", var.bedrock_max_input_tokens > 0 ? "bedrock-invocations" : "n/a"]
          ]
        }
      },
      {
        type       = "metric"
        properties = {
          title  = "Cognito Authentication Success vs Failure"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/Cognito", "SignInSuccesses", "UserPool", var.cognito_user_pool_id],
            ["AWS/Cognito", "TokenRefreshSuccesses", "UserPool", var.cognito_user_pool_id]
          ]
        }
      }
    ]
  })
}

# API Gateway 5xx alarm
resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name          = "${var.name_prefix}-api-5xx-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = var.api_5xx_threshold_pct
  alarm_description   = "P2: API Gateway 5xx error rate elevated"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    ApiName = "${var.name_prefix}-api"
    Stage   = var.api_stage_name
  }
  tags = var.common_tags
}

# Cognito authentication failure alarm
resource "aws_cloudwatch_metric_alarm" "cognito_auth_failures" {
  alarm_name          = "${var.name_prefix}-cognito-auth-failure-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "SignInThrottles"
  namespace           = "AWS/Cognito"
  period              = 300
  statistic           = "Sum"
  threshold           = var.cognito_auth_failure_pct
  alarm_description   = "P2: Cognito authentication failures elevated — check for credential-stuffing"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    UserPool = var.cognito_user_pool_id
  }
  tags = var.common_tags
}

# CloudWatch Synthetics canary for API health check
resource "aws_iam_role" "canary" {
  name = "${var.name_prefix}-canary-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "canary_basic" {
  role       = aws_iam_role.canary.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchSyntheticsFullAccess"
}
