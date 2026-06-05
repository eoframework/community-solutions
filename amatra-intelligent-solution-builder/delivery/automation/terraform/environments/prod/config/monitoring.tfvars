#------------------------------------------------------------------------------
# Monitoring Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 16:27:28
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  # SNS topic ARN for operational and security CloudWatch alarms
  alarm_sns_topic_arn = "[sns-alarm-topic-arn]"  # TODO: Replace with actual value
  # Daily Bedrock spend as a percentage of daily budget target that triggers alarm
  bedrock_daily_spend_alarm_pct = 110
  # CloudWatch dashboard name for platform operational metrics
  cloudwatch_dashboard_name = "amatra-prod-health"
  # Lambda error rate (%) threshold that triggers a CloudWatch alarm
  lambda_error_rate_alarm_threshold = "1"
  # CloudWatch Logs retention period in days for all log groups
  log_retention_days = 90
  # CloudWatch custom metrics namespace for token usage and latency
  metrics_namespace = "AmatraPlatform"
  # Step Functions execution failure rate (%) threshold for alarm
  stepfunctions_failure_rate_alarm_threshold = "2"
  # CloudWatch custom metric name for per-phase agent token usage
  token_usage_metric_name = "TokenUsage"
}
