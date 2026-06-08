#------------------------------------------------------------------------------
# Tier 2 — Monitoring: SNS alert topic, CloudWatch dashboards, and
# SageMaker endpoint health alarms
#------------------------------------------------------------------------------

module "sns" {
  source = "../aws/sns"

  topic_name  = "${var.name_prefix}-alerts"
  name_prefix = var.name_prefix
  common_tags = var.common_tags
}

#-- CloudWatch Dashboards -----------------------------------------------------

resource "aws_cloudwatch_dashboard" "api_health" {
  dashboard_name = var.cloudwatch_dashboard_api

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "API Gateway Latency (p95)"
          view   = "timeSeries"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/ApiGateway", "IntegrationLatency", "ApiName", "${var.name_prefix}-recommendation-api"]
          ]
          period = 60
          stat   = "p95"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "API Gateway 5xx Errors"
          view   = "timeSeries"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/ApiGateway", "5XXError", "ApiName", "${var.name_prefix}-recommendation-api"]
          ]
          period = 60
          stat   = "Sum"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "ml_pipeline" {
  dashboard_name = var.cloudwatch_dashboard_ml

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "SageMaker NLP Endpoint Invocations"
          view   = "timeSeries"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/SageMaker", "Invocations", "EndpointName", var.sagemaker_nlp_endpoint_name]
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "SageMaker NLP ModelErrors"
          view   = "timeSeries"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/SageMaker", "ModelError", "EndpointName", var.sagemaker_nlp_endpoint_name]
          ]
          period = 300
          stat   = "Sum"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "business_metrics" {
  dashboard_name = var.cloudwatch_dashboard_business

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "API Request Count"
          view   = "timeSeries"
          region = data.aws_region.current.name
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", "${var.name_prefix}-recommendation-api"]
          ]
          period = 3600
          stat   = "Sum"
        }
      }
    ]
  })
}

#-- SageMaker Endpoint Alarms ------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "sagemaker_nlp_errors" {
  alarm_name          = "${var.name_prefix}-sagemaker-nlp-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ModelError"
  namespace           = "AWS/SageMaker"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alarm_sagemaker_error_pct
  alarm_description   = "SageMaker NLP endpoint ModelError rate exceeds threshold"
  alarm_actions       = [module.sns.topic_arn]
  ok_actions          = [module.sns.topic_arn]
  dimensions = {
    EndpointName = var.sagemaker_nlp_endpoint_name
  }
}

resource "aws_cloudwatch_metric_alarm" "sagemaker_audio_errors" {
  alarm_name          = "${var.name_prefix}-sagemaker-audio-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ModelError"
  namespace           = "AWS/SageMaker"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alarm_sagemaker_error_pct
  alarm_description   = "SageMaker audio endpoint ModelError rate exceeds threshold"
  alarm_actions       = [module.sns.topic_arn]
  ok_actions          = [module.sns.topic_arn]
  dimensions = {
    EndpointName = var.sagemaker_audio_endpoint_name
  }
}

data "aws_region" "current" {}
