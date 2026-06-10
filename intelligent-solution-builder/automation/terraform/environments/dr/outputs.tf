#------------------------------------------------------------------------------
# Amatra ISB — DR Outputs
#------------------------------------------------------------------------------

output "environment" {
  description = "Deployment environment name"
  value       = local.environment
}

output "aws_region" {
  description = "AWS region for DR resources"
  value       = var.aws.region
}

output "kms_s3_key_arn" {
  description = "KMS CMK ARN for S3 bucket encryption (DR region)"
  value       = module.kms.s3_key_arn
}

output "kms_dynamodb_key_arn" {
  description = "KMS CMK ARN for DynamoDB table encryption (DR region)"
  value       = module.kms.dynamodb_key_arn
}

output "kms_cloudtrail_key_arn" {
  description = "KMS CMK ARN for CloudTrail log bucket encryption (DR region)"
  value       = module.kms.cloudtrail_key_arn
}

output "kms_secrets_key_arn" {
  description = "KMS CMK ARN for Secrets Manager encryption (DR region)"
  value       = module.kms.secrets_key_arn
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID (DR)"
  value       = module.security.cognito_user_pool_id
}

output "artifacts_bucket_name" {
  description = "S3 bucket name for generated artifacts (DR)"
  value       = module.storage.artifacts_bucket_name
}

output "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs (DR independent audit trail)"
  value       = module.storage.cloudtrail_bucket_name
}

output "solution_state_table_name" {
  description = "DynamoDB solution state table name (DR)"
  value       = module.database.solution_state_table_name
}

output "usage_tracking_table_name" {
  description = "DynamoDB usage tracking table name (DR)"
  value       = module.database.usage_tracking_table_name
}

output "job_queue_url" {
  description = "SQS job queue URL (DR)"
  value       = module.messaging.job_queue_url
}

output "dlq_url" {
  description = "SQS Dead Letter Queue URL (DR)"
  value       = module.messaging.dlq_url
}

output "api_gateway_id" {
  description = "API Gateway REST API ID (DR)"
  value       = module.api.rest_api_id
}

output "api_gateway_invoke_url" {
  description = "API Gateway invoke URL (DR standby endpoint)"
  value       = module.api.invoke_url
}

output "state_machine_arn" {
  description = "Step Functions state machine ARN (DR)"
  value       = module.orchestration.state_machine_arn
}

output "sns_alerts_topic_arn" {
  description = "SNS alerts topic ARN (DR)"
  value       = module.monitoring.sns_topic_arn
}
