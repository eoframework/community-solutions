#------------------------------------------------------------------------------
# Production Environment — Outputs
#------------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "api_endpoint" {
  description = "API Gateway HTTP API v2 endpoint URL"
  value       = module.api.api_endpoint
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.security.cognito_user_pool_id
}

output "cognito_app_client_id" {
  description = "Cognito App Client ID"
  value       = module.security.cognito_app_client_id
}

output "artifact_bucket_name" {
  description = "Artifact S3 bucket name"
  value       = module.storage.artifact_bucket_id
}

output "ecr_repository_url" {
  description = "ECR repository URL for agent container image"
  value       = module.compute.ecr_repository_url
}

output "sns_ops_alerts_arn" {
  description = "SNS operations alerts topic ARN"
  value       = module.monitoring.sns_ops_alerts_arn
}

output "users_table_name" {
  description = "Users DynamoDB table name"
  value       = module.database.users_table_name
}

output "solutions_table_name" {
  description = "Solutions DynamoDB table name"
  value       = module.database.solutions_table_name
}

output "quotas_table_name" {
  description = "Quotas DynamoDB table name"
  value       = module.database.quotas_table_name
}

output "audit_events_table_name" {
  description = "Audit events DynamoDB table name"
  value       = module.database.audit_events_table_name
}

output "github_dlq_url" {
  description = "GitHub push Dead Letter Queue URL"
  value       = module.api.github_dlq_url
}

output "cloudtrail_arn" {
  description = "CloudTrail trail ARN"
  value       = module.monitoring.cloudtrail_arn
}

output "kms_s3_key_arn" {
  description = "KMS CMK ARN for S3 encryption"
  value       = module.security.kms_s3_key_arn
}
