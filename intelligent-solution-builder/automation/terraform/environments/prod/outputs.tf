#------------------------------------------------------------------------------
# Amatra ISB — Production Outputs
#------------------------------------------------------------------------------

output "environment" {
  description = "Deployment environment name"
  value       = local.environment
}

output "aws_region" {
  description = "AWS region for all resources"
  value       = var.aws.region
}

# ---------------------------------------------------------------------------
# KMS Key ARNs
# ---------------------------------------------------------------------------
output "kms_s3_key_arn" {
  description = "KMS CMK ARN for S3 artifact bucket encryption"
  value       = module.kms.s3_key_arn
}

output "kms_dynamodb_key_arn" {
  description = "KMS CMK ARN for DynamoDB table encryption"
  value       = module.kms.dynamodb_key_arn
}

output "kms_cloudtrail_key_arn" {
  description = "KMS CMK ARN for CloudTrail log bucket encryption"
  value       = module.kms.cloudtrail_key_arn
}

output "kms_secrets_key_arn" {
  description = "KMS CMK ARN for Secrets Manager encryption"
  value       = module.kms.secrets_key_arn
}

# ---------------------------------------------------------------------------
# Security
# ---------------------------------------------------------------------------
output "cognito_user_pool_id" {
  description = "Cognito User Pool ID for platform authentication"
  value       = module.security.cognito_user_pool_id
}

output "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = module.security.cognito_user_pool_arn
}

output "waf_web_acl_arn" {
  description = "WAF WebACL ARN attached to API Gateway"
  value       = module.security.waf_web_acl_arn
}

# ---------------------------------------------------------------------------
# Storage
# ---------------------------------------------------------------------------
output "artifacts_bucket_name" {
  description = "S3 bucket name for generated artifacts"
  value       = module.storage.artifacts_bucket_name
}

output "templates_bucket_name" {
  description = "S3 bucket name for Bedrock prompt templates"
  value       = module.storage.templates_bucket_name
}

output "cloudtrail_bucket_name" {
  description = "S3 bucket name for immutable CloudTrail audit logs"
  value       = module.storage.cloudtrail_bucket_name
}

# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------
output "solution_state_table_name" {
  description = "DynamoDB table name for solution job state tracking"
  value       = module.database.solution_state_table_name
}

output "usage_tracking_table_name" {
  description = "DynamoDB table name for per-user/global usage counters"
  value       = module.database.usage_tracking_table_name
}

# ---------------------------------------------------------------------------
# Messaging
# ---------------------------------------------------------------------------
output "job_queue_url" {
  description = "SQS job queue URL for async generation jobs"
  value       = module.messaging.job_queue_url
}

output "job_queue_arn" {
  description = "SQS job queue ARN"
  value       = module.messaging.job_queue_arn
}

output "dlq_url" {
  description = "SQS Dead Letter Queue URL"
  value       = module.messaging.dlq_url
}

# ---------------------------------------------------------------------------
# API Gateway
# ---------------------------------------------------------------------------
output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = module.api.rest_api_id
}

output "api_gateway_invoke_url" {
  description = "API Gateway invoke URL for the platform stage"
  value       = module.api.invoke_url
}

output "api_gateway_stage_arn" {
  description = "API Gateway stage ARN (used for WAF association)"
  value       = module.api.stage_arn
}

# ---------------------------------------------------------------------------
# Compute (Lambda ARNs)
# ---------------------------------------------------------------------------
output "api_submit_lambda_arn" {
  description = "ARN of the brief-submission API Handler Lambda"
  value       = module.compute.api_submit_lambda_arn
}

output "bedrock_sonnet_lambda_arn" {
  description = "ARN of the Bedrock Sonnet invoker Lambda"
  value       = module.compute.bedrock_sonnet_lambda_arn
}

output "bedrock_haiku_lambda_arn" {
  description = "ARN of the Bedrock Haiku invoker Lambda"
  value       = module.compute.bedrock_haiku_lambda_arn
}

output "artifact_processor_lambda_arn" {
  description = "ARN of the Artifact Processor / QA Lambda"
  value       = module.compute.artifact_processor_lambda_arn
}

# ---------------------------------------------------------------------------
# Step Functions
# ---------------------------------------------------------------------------
output "state_machine_arn" {
  description = "Step Functions state machine ARN for generation workflow"
  value       = module.orchestration.state_machine_arn
}

output "state_machine_name" {
  description = "Step Functions state machine name"
  value       = module.orchestration.state_machine_name
}

# ---------------------------------------------------------------------------
# Monitoring
# ---------------------------------------------------------------------------
output "sns_alerts_topic_arn" {
  description = "SNS topic ARN for operational alerts (P1→PagerDuty, P2→Slack)"
  value       = module.monitoring.sns_topic_arn
}

output "operations_dashboard_name" {
  description = "CloudWatch Operations Dashboard name"
  value       = module.monitoring.operations_dashboard_name
}

output "sla_dashboard_name" {
  description = "CloudWatch SLA Dashboard name"
  value       = module.monitoring.sla_dashboard_name
}

output "quality_dashboard_name" {
  description = "CloudWatch Quality & Usage Dashboard name"
  value       = module.monitoring.quality_dashboard_name
}
