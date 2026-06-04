#------------------------------------------------------------------------------
# Tier 1: AWS CloudWatch — Four operational dashboards for the platform
#------------------------------------------------------------------------------

# Dashboard 1: Platform Health — Lambda errors, DynamoDB throttles, API GW 4xx/5xx
resource "aws_cloudwatch_dashboard" "platform_health" {
  dashboard_name = var.dashboard_platform_health

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Error Rates"
          region = var.aws_region
          metrics = [
            ["AWS/Lambda", "Errors", { stat = "Sum", period = 300, label = "All Lambda Errors" }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "API Gateway 4xx/5xx Rates"
          region = var.aws_region
          metrics = [
            ["AWS/ApiGateway", "4XXError", { stat = "Sum", period = 300, label = "4xx Errors" }],
            ["AWS/ApiGateway", "5XXError", { stat = "Sum", period = 300, label = "5xx Errors" }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "DynamoDB Throttled Requests"
          region = var.aws_region
          metrics = [
            ["AWS/DynamoDB", "ThrottledRequests", { stat = "Sum", period = 300, label = "DynamoDB Throttles" }]
          ]
          view = "timeSeries"
        }
      }
    ]
  })
}

# Dashboard 2: Solution Throughput
resource "aws_cloudwatch_dashboard" "throughput" {
  dashboard_name = var.dashboard_throughput

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 24
        height = 6
        properties = {
          title  = "Solutions Generated"
          region = var.aws_region
          metrics = [
            ["AWS/Lambda", "Invocations", { stat = "Sum", period = 86400, label = "Daily Solution Invocations" }]
          ]
          view = "timeSeries"
        }
      }
    ]
  })
}

# Dashboard 3: Cost Telemetry — Bedrock token spend by model and phase
resource "aws_cloudwatch_dashboard" "cost_telemetry" {
  dashboard_name = var.dashboard_cost_telemetry

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2
        properties = {
          markdown = "## Bedrock Cost Telemetry\nCustom metrics emitted by Lambda functions: `BedrockTokenUsage/GenerationTokens` and `BedrockTokenUsage/ValidationTokens`"
        }
      }
    ]
  })
}

# Dashboard 4: Quota Utilisation
resource "aws_cloudwatch_dashboard" "quota_utilisation" {
  dashboard_name = var.dashboard_quota_utilisation

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2
        properties = {
          markdown = "## Quota Utilisation\nCustom metrics emitted by Lambda functions: `QuotaEnforcement/GlobalQuotaUsed` and `QuotaEnforcement/UserQuotaUsed`"
        }
      }
    ]
  })
}
