#------------------------------------------------------------------------------
# Amatra Agentic Orchestration Platform — DR Outputs
#------------------------------------------------------------------------------

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID — used by API Gateway JWT authoriser"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = module.cognito.user_pool_arn
}

output "cognito_app_client_id" {
  description = "Cognito App Client ID — used by CLI for USER_PASSWORD_AUTH"
  value       = module.cognito.app_client_id
  sensitive   = true
}

output "api_gateway_api_id" {
  description = "API Gateway HTTP API v2 ID"
  value       = module.api_gateway.api_id
}

output "api_gateway_stage_arn" {
  description = "API Gateway stage ARN"
  value       = module.api_gateway.stage_arn
}

output "api_gateway_endpoint" {
  description = "API Gateway HTTP API v2 invoke URL"
  value       = module.api_gateway.api_endpoint
}

output "solution_create_function_arn" {
  description = "Solution Create Lambda function ARN"
  value       = module.lambda.solution_create_function_arn
}

output "github_integration_function_arn" {
  description = "GitHub Integration Lambda function ARN"
  value       = module.lambda.github_integration_function_arn
}

output "users_table_arn" {
  description = "DynamoDB Users table ARN"
  value       = module.database.users_table_arn
}

output "solutions_table_arn" {
  description = "DynamoDB Solutions table ARN"
  value       = module.database.solutions_table_arn
}

output "global_quota_table_arn" {
  description = "DynamoDB GlobalQuota table ARN"
  value       = module.database.global_quota_table_arn
}

output "artifacts_bucket_name" {
  description = "S3 artifacts bucket name"
  value       = module.storage.artifacts_bucket_name
}

output "artifacts_bucket_arn" {
  description = "S3 artifacts bucket ARN"
  value       = module.storage.artifacts_bucket_arn
}

output "guidance_bucket_name" {
  description = "S3 guidance bucket name"
  value       = module.storage.guidance_bucket_name
}

output "ecr_repository_url" {
  description = "ECR repository URL for agent container images"
  value       = module.ecr.repository_url
}

output "sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications"
  value       = module.monitoring.sns_topic_arn
}
