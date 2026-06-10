#------------------------------------------------------------------------------
# Monitoring Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-10 02:56:40
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  # API Gateway 5xx error rate percentage threshold that triggers a P2 Slack alert
  alarm_api_5xx_threshold_pct = 1
  # Bedrock monthly token consumption percentage threshold that triggers a P3 email alert
  alarm_bedrock_budget_warning_pct = 80
  # Cognito authentication failure rate percentage threshold triggering a P2 alert and GuardDuty review
  alarm_cognito_auth_failure_pct = 10
  # SQS DLQ message count threshold that triggers a P1 alert
  alarm_dlq_depth_threshold = 1
  # Async job failure rate percentage threshold that triggers a P1 PagerDuty alert
  alarm_job_failure_rate_threshold_pct = 5
  # Retention period in days for all Lambda function CloudWatch Log Groups
  cloudwatch_log_retention_days = 90
  # CloudWatch dashboard name for real-time async job queue depth and Lambda error rates
  cloudwatch_operations_dashboard = "amatra-isb-operations-prod"
  # CloudWatch dashboard name for QA first-pass acceptance rate and Bedrock token consumption
  cloudwatch_quality_dashboard = "amatra-isb-quality-prod"
  # CloudWatch dashboard name for monthly availability percentage and job completion rate vs SLA targets
  cloudwatch_sla_dashboard = "amatra-isb-sla-prod"
  # SNS topic ARN for operational alerts routing to PagerDuty (P1) and Slack (P2)
  sns_alerts_topic_arn = "[sns-alerts-topic-arn]"  # TODO: Replace with actual value
  # CloudWatch Synthetics canary polling interval in seconds for GET /api/v1/health availability measurement
  synthetics_health_check_interval_seconds = 60
}
