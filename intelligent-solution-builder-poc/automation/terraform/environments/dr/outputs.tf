###############################################################################
# DR Environment — Outputs
###############################################################################

output "vpc_id" {
  description = "DR VPC ID"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "DR private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "kms_artifacts_key_arn" {
  description = "DR KMS artifacts key ARN"
  value       = module.security.kms_artifacts_key_arn
  sensitive   = true
}

output "kms_database_key_arn" {
  description = "DR KMS database key ARN"
  value       = module.security.kms_database_key_arn
  sensitive   = true
}

output "cognito_user_pool_id" {
  description = "DR Cognito User Pool ID"
  value       = module.identity.user_pool_id
  sensitive   = true
}

output "artifacts_bucket_id" {
  description = "DR artifacts S3 bucket name (replication target)"
  value       = module.storage.artifacts_bucket_id
}

output "artifacts_bucket_arn" {
  description = "DR artifacts S3 bucket ARN"
  value       = module.storage.artifacts_bucket_arn
}

output "solution_state_table_name" {
  description = "DR solution state DynamoDB table"
  value       = module.storage.solution_state_table_name
}

output "step_functions_arn" {
  description = "DR Step Functions state machine ARN"
  value       = module.compute.step_functions_arn
}

output "api_gateway_id" {
  description = "DR API Gateway REST API ID"
  value       = module.api.rest_api_id
}

output "sns_topic_arn" {
  description = "DR SNS operations alert topic ARN"
  value       = module.monitoring.sns_topic_arn
}

output "cloudtrail_arn" {
  description = "DR CloudTrail trail ARN"
  value       = module.monitoring.cloudtrail_arn
}
