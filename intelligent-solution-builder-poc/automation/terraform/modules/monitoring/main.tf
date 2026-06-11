###############################################################################
# Tier 2 Solution Module — Monitoring
# Composes CloudWatch (SNS + dashboard) and CloudTrail for the ISB platform.
###############################################################################

module "cloudwatch" {
  source = "../aws/cloudwatch"

  name_prefix    = var.name_prefix
  dashboard_name = var.dashboard_name
  kms_key_id     = var.kms_audit_key_arn

  api_name              = var.api_name
  step_functions_arn    = var.step_functions_arn
  generation_queue_name = var.generation_queue_name
  dlq_name              = var.dlq_name

  common_tags = var.common_tags
}

module "cloudtrail" {
  source = "../aws/cloudtrail"

  trail_name             = var.trail_name
  cloudtrail_bucket_name = var.cloudtrail_bucket_name
  kms_key_arn            = var.kms_audit_key_arn
  include_data_events    = var.cloudtrail_include_data_events
  force_destroy          = var.force_destroy
  common_tags            = var.common_tags
}

#--------------------------------------
# CloudWatch Alarms (API + SFN + DLQ)
#--------------------------------------
resource "aws_cloudwatch_metric_alarm" "api_5xx_error_rate" {
  alarm_name          = "${var.name_prefix}-api-5xx-error-rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 60
  statistic           = "Average"
  threshold           = var.api_error_rate_threshold_pct / 100
  alarm_description   = "Platform-Availability-Critical — API 5xx error rate exceeded ${var.api_error_rate_threshold_pct}%"
  alarm_actions       = [module.cloudwatch.sns_topic_arn]
  ok_actions          = [module.cloudwatch.sns_topic_arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = var.api_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${var.name_prefix}-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = var.dlq_message_threshold
  alarm_description   = "DLQ-Message-Received — Failed job in dead-letter queue"
  alarm_actions       = [module.cloudwatch.sns_topic_arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = var.dlq_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "step_functions_failures" {
  alarm_name          = "${var.name_prefix}-sfn-failure-rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ExecutionsFailed"
  namespace           = "AWS/States"
  period              = 300
  statistic           = "Sum"
  threshold           = var.sfn_failure_threshold
  alarm_description   = "Step-Functions-Failure-Rate — Workflow execution failures exceeded threshold"
  alarm_actions       = [module.cloudwatch.sns_topic_arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    StateMachineArn = var.step_functions_arn
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "api_latency_p95" {
  alarm_name          = "${var.name_prefix}-api-latency-p95"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = 60
  extended_statistic  = "p95"
  threshold           = var.api_latency_p95_threshold_ms
  alarm_description   = "API-Latency-P95-Breach — P95 latency exceeded ${var.api_latency_p95_threshold_ms}ms"
  alarm_actions       = [module.cloudwatch.sns_topic_arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = var.api_name
  }

  tags = var.common_tags
}
