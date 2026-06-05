#------------------------------------------------------------------------------
# Monitoring Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 19:11:53
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  # Bedrock ThrottlingException count per 5-minute window before alarm fires
  alarm_bedrock_throttle_count = 5
  # Percentage of global monthly quota (1000 solutions) that triggers P3 warning alarm
  alarm_global_quota_threshold_pct = 90
  # Lambda error rate alarm threshold as a percentage; triggers P2 alert to ops team
  alarm_lambda_error_rate_pct = "1"
  # SNS topic ARN for all CloudWatch Alarms; email subscriptions for Daniel Park and ops on-call
  alert_sns_topic_arn = "[sns-ops-alerts-arn]"  # TODO: Replace with actual value
  # API Gateway P99 latency SLA target in milliseconds for synchronous routes per SOW
  api_gateway_p99_latency_ms = 3000
  # Alert threshold for estimated per-solution Bedrock cost in USD; matches SOW success metric
  bedrock_cost_per_solution_alert_usd = "5.00"
  # CloudWatch Synthetics canary polling interval in minutes for /api/v1/health route
  canary_health_check_interval_minutes = 5
  # CloudWatch dashboard name for real-time Lambda / DynamoDB / Bedrock operational visibility
  cloudwatch_dashboard_name = "eofw-prd-health"
  # CloudWatch Logs retention for CloudTrail delivery to CloudWatch Logs group
  log_retention_cloudtrail_days = 365
  # CloudWatch Log Group retention in days for the 17 Lambda function log groups
  log_retention_lambda_days = 90
  # X-Ray trace sampling rate; 5% in production / 100% in dev for full distributed tracing
  xray_sampling_rate = "0.05"
}
