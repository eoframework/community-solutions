#------------------------------------------------------------------------------
# Monitoring Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 01:56:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  # CloudWatch Alarm threshold: API Gateway 5xx error count over a 5-minute window
  alarm_apigw_5xx_count = 5
  # CloudWatch Alarm threshold: API Gateway p95 latency in milliseconds over a 5-minute window
  alarm_apigw_p95_latency_ms = 2000
  # CloudWatch Alarm threshold: Auto-Tagger SQS DLQ visible message count
  alarm_autotagger_dlq_depth = 0
  # CloudWatch Alarm threshold: Bedrock monthly token consumption as percentage of monthly budget
  alarm_bedrock_token_budget_pct = 90
  # CloudWatch Alarm threshold: Classifier Lambda error percentage over a 5-minute window
  alarm_classifier_error_rate_pct = "1"
  # CloudWatch Alarm threshold: DynamoDB ThrottledRequests metric count over a 5-minute window
  alarm_dynamodb_throttle_count = 0
  # CloudWatch Alarm threshold: Recommender Lambda error percentage over a 5-minute window
  alarm_recommender_error_rate_pct = "1"
  # CloudWatch dashboard name for Bedrock token consumption and DynamoDB capacity cost tracking
  cloudwatch_dashboard_cost = "ANP-Cost-Tracking"
  # CloudWatch dashboard name for API monitoring covering invocations; error rates; p95 latency
  cloudwatch_dashboard_operations = "ANP-Operations"
  # CloudWatch log group retention in days for all Lambda and API Gateway log groups
  cloudwatch_log_retention_days = 30
  # Enable AWS X-Ray tracing on Lambda functions and API Gateway stages
  cloudwatch_xray_enabled = true
  # SNS topic ARN used to deliver all CloudWatch alarm notifications to ANP operations team
  sns_ops_topic_arn = "[sns-ops-topic-arn]"  # TODO: Replace with actual value
}
