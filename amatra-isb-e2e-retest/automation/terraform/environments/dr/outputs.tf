#------------------------------------------------------------------------------
# DR Environment — Outputs
#------------------------------------------------------------------------------

output "vpc_id" {
  description = "DR VPC ID"
  value       = module.networking.vpc_id
}

output "api_endpoint" {
  description = "DR API Gateway endpoint URL"
  value       = module.api.api_endpoint
}

output "cognito_user_pool_id" {
  description = "DR Cognito User Pool ID"
  value       = module.security.cognito_user_pool_id
}

output "cognito_app_client_id" {
  description = "DR Cognito App Client ID"
  value       = module.security.cognito_app_client_id
}

output "artifact_bucket_name" {
  description = "DR Artifact S3 bucket name"
  value       = module.storage.artifact_bucket_id
}

output "ecr_repository_url" {
  description = "DR ECR repository URL"
  value       = module.compute.ecr_repository_url
}

output "sns_ops_alerts_arn" {
  description = "DR SNS operations alerts topic ARN"
  value       = module.monitoring.sns_ops_alerts_arn
}

output "users_table_name" {
  description = "DR Users DynamoDB table name"
  value       = module.database.users_table_name
}

output "solutions_table_name" {
  description = "DR Solutions DynamoDB table name"
  value       = module.database.solutions_table_name
}

output "quotas_table_name" {
  description = "DR Quotas DynamoDB table name"
  value       = module.database.quotas_table_name
}

output "audit_events_table_name" {
  description = "DR Audit events DynamoDB table name"
  value       = module.database.audit_events_table_name
}

output "github_dlq_url" {
  description = "DR GitHub push Dead Letter Queue URL"
  value       = module.api.github_dlq_url
}

output "cloudtrail_arn" {
  description = "DR CloudTrail trail ARN"
  value       = module.monitoring.cloudtrail_arn
}

output "kms_s3_key_arn" {
  description = "DR KMS CMK ARN for S3 encryption"
  value       = module.security.kms_s3_key_arn
}
