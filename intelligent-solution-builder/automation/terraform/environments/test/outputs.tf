#------------------------------------------------------------------------------
# Amatra ISB — Test Outputs
#------------------------------------------------------------------------------

output "environment" {
  description = "Deployment environment name"
  value       = local.environment
}

output "aws_region" {
  description = "AWS region for all resources"
  value       = var.aws.region
}

output "kms_s3_key_arn" {
  description = "KMS CMK ARN for S3 bucket encryption"
  value       = module.kms.s3_key_arn
}

output "kms_dynamodb_key_arn" {
  description = "KMS CMK ARN for DynamoDB table encryption"
  value       = module.kms.dynamodb_key_arn
}

output "kms_secrets_key_arn" {
  description = "KMS CMK ARN for Secrets Manager encryption"
  value       = module.kms.secrets_key_arn
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.security.cognito_user_pool_id
}

output "artifacts_bucket_name" {
  description = "S3 bucket name for generated artifacts"
  value       = module.storage.artifacts_bucket_name
}

output "solution_state_table_name" {
  description = "DynamoDB table name for solution job state tracking"
  value       = module.database.solution_state_table_name
}

output "usage_tracking_table_name" {
  description = "DynamoDB table name for usage counters"
  value       = module.database.usage_tracking_table_name
}

output "job_queue_url" {
  description = "SQS job queue URL"
  value       = module.messaging.job_queue_url
}

output "dlq_url" {
  description = "SQS Dead Letter Queue URL"
  value       = module.messaging.dlq_url
}

output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = module.api.rest_api_id
}

output "api_gateway_invoke_url" {
  description = "API Gateway invoke URL"
  value       = module.api.invoke_url
}

output "state_machine_arn" {
  description = "Step Functions state machine ARN"
  value       = module.orchestration.state_machine_arn
}

output "sns_alerts_topic_arn" {
  description = "SNS alerts topic ARN"
  value       = module.monitoring.sns_topic_arn
}
