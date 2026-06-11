###############################################################################
# Test Environment — Outputs
###############################################################################

output "vpc_id" {
  description = "Platform VPC ID"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "kms_artifacts_key_arn" {
  description = "KMS artifacts key ARN"
  value       = module.security.kms_artifacts_key_arn
  sensitive   = true
}

output "kms_database_key_arn" {
  description = "KMS database key ARN"
  value       = module.security.kms_database_key_arn
  sensitive   = true
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.identity.user_pool_id
  sensitive   = true
}

output "cognito_app_client_id" {
  description = "Cognito App Client ID"
  value       = module.identity.app_client_id
  sensitive   = true
}

output "artifacts_bucket_id" {
  description = "Artifacts S3 bucket name"
  value       = module.storage.artifacts_bucket_id
}

output "solution_state_table_name" {
  description = "Solution state DynamoDB table name"
  value       = module.storage.solution_state_table_name
}

output "generation_queue_url" {
  description = "SQS generation queue URL"
  value       = module.compute.generation_queue_url
}

output "step_functions_arn" {
  description = "Step Functions state machine ARN"
  value       = module.compute.step_functions_arn
}

output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = module.api.rest_api_id
}

output "sns_topic_arn" {
  description = "SNS operations alert topic ARN"
  value       = module.monitoring.sns_topic_arn
}

output "ecr_repository_urls" {
  description = "ECR repository URLs per Lambda function"
  value       = module.compute.ecr_repository_urls
}
