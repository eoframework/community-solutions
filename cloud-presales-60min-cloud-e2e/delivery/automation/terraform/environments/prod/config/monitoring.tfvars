#------------------------------------------------------------------------------
# Monitoring Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-04 19:28:42
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  # Per-solution Bedrock token spend threshold in USD above which an anomaly alarm fires
  alerts_bedrock_cost_anomaly_threshold_usd = "10.00"
  # Lambda error rate percentage threshold that triggers a P2 CloudWatch alarm
  alerts_lambda_error_rate_threshold_pct = "5"
  # SNS topic ARN populated post-Terraform provisioning; referenced by all CloudWatch Alarm actions
  alerts_sns_topic_arn = "[sns-topic-arn]"  # TODO: Replace with actual value
  # SNS topic name for all CloudWatch alarm notifications to Daniel Park's operations team
  alerts_sns_topic_name = "amatra-prod-ops-alerts"
  # CloudWatch Synthetic Canary target endpoint path for availability monitoring every 5 minutes
  canary_endpoint_path = "/v1/quota"
  # CloudWatch Synthetic Canary execution interval in minutes
  canary_interval_minutes = 5
  # CloudWatch Log Group retention for CloudTrail forwarded logs used for real-time security alerting
  cloudwatch_cloudtrail_log_retention_days = 365
  # CloudWatch dashboard name for Bedrock token spend by model and phase per-solution cost trend view
  cloudwatch_dashboard_cost_telemetry = "amatra-prod-cost-telemetry"
  # CloudWatch dashboard name for Lambda errors / DynamoDB throttles / API Gateway 4xx-5xx view
  cloudwatch_dashboard_platform_health = "amatra-prod-platform-health"
  # CloudWatch dashboard name for per-user and global quota consumption heat map view
  cloudwatch_dashboard_quota_utilisation = "amatra-prod-quota-utilisation"
  # CloudWatch dashboard name for solutions per day/week/month and validation pass-rate view
  cloudwatch_dashboard_throughput = "amatra-prod-solution-throughput"
  # CloudWatch Log Group retention period in days for all Lambda function and agent logs
  cloudwatch_log_retention_days = 30
  # Enable AWS X-Ray distributed tracing on all Lambda functions and API Gateway stage
  cloudwatch_xray_tracing_enabled = true
}
