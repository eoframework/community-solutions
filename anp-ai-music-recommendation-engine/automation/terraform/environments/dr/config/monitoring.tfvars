#------------------------------------------------------------------------------
# Monitoring Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-08 21:29:43
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  # API Gateway 5xx error-rate percentage threshold for critical alarm
  alarm_api_5xx_pct = 1
  # SQS DLQ message count threshold for high-severity alarm
  alarm_dlq_message_count = 10
  # API Gateway p95 latency threshold in ms above which alarm fires
  alarm_playlist_latency_ms = 3000
  # SageMaker ModelError percentage threshold triggering critical alarm
  alarm_sagemaker_error_pct = 5
  # SNS topic ARN for operational alerts to ANP Technical Lead
  alert_sns_topic_arn = "[sns-alerts-topic-arn]"  # TODO: Replace with actual value
  # CloudWatch Synthetics canary polling interval for the health endpoint
  canary_interval_minutes = 5
  # CloudWatch dashboard name covering API Gateway latency and error metrics
  cloudwatch_dashboard_api = "anp-prod-api-health"
  # CloudWatch dashboard name covering business KPI metrics
  cloudwatch_dashboard_business = "anp-prod-business-metrics"
  # CloudWatch dashboard name covering ML pipeline metrics
  cloudwatch_dashboard_ml = "anp-prod-ml-pipeline"
  # CloudWatch log group retention in days for all platform components
  log_retention_days = 90
  # Enable AWS X-Ray active tracing on all Lambda functions and API Gateway
  xray_tracing_enabled = true
}
