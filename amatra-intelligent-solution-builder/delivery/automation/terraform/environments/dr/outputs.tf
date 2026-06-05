#------------------------------------------------------------------------------
# Amatra Agentic Pre-Sales Platform — DR Outputs
#------------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC ID for the DR platform network"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (AZ1, AZ2, AZ3) hosting Lambda and AgentCore"
  value       = module.networking.private_subnet_ids
}

output "kms_key_arn" {
  description = "Customer-managed KMS key ARN for S3 and CloudWatch Logs encryption — DR region"
  value       = module.kms.key_arn
}

output "kms_key_id" {
  description = "Customer-managed KMS key ID — DR region"
  value       = module.kms.key_id
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID — DR environment"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN — DR environment"
  value       = module.cognito.user_pool_arn
}

output "cognito_user_pool_endpoint" {
  description = "Cognito User Pool JWKS endpoint — DR environment"
  value       = module.cognito.user_pool_endpoint
}

output "api_gateway_endpoint" {
  description = "API Gateway HTTP API v2 invoke URL — DR environment"
  value       = module.api_gateway.api_endpoint
}

output "api_gateway_id" {
  description = "API Gateway HTTP API ID — DR environment"
  value       = module.api_gateway.api_id
}

output "artifact_bucket_name" {
  description = "S3 artifact bucket name — DR environment"
  value       = module.storage.artifact_bucket_name
}

output "artifact_bucket_arn" {
  description = "S3 artifact bucket ARN — DR environment"
  value       = module.storage.artifact_bucket_arn
}

output "cloudtrail_bucket_name" {
  description = "S3 CloudTrail audit bucket name — DR environment"
  value       = module.storage.cloudtrail_bucket_name
}

output "table_user_profiles_name" {
  description = "DynamoDB user profiles table name — DR environment"
  value       = module.database.table_user_profiles_name
}

output "table_solution_state_name" {
  description = "DynamoDB solution state table name — DR environment"
  value       = module.database.table_solution_state_name
}

output "table_quota_global_name" {
  description = "DynamoDB global quota table name — DR environment"
  value       = module.database.table_quota_global_name
}

output "ecr_repository_url" {
  description = "ECR repository URL for AgentCore Docker images — DR environment"
  value       = module.ecr.repository_url
}

output "stepfunctions_state_machine_arn" {
  description = "Step Functions state machine ARN — DR environment"
  value       = module.stepfunctions.state_machine_arn
}

output "sns_alarm_topic_arn" {
  description = "SNS alarm topic ARN — DR environment"
  value       = module.monitoring.sns_topic_arn
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name — DR environment"
  value       = module.monitoring.dashboard_name
}

output "github_pat_secret_arn" {
  description = "Secrets Manager ARN for the GitHub PAT — DR environment"
  value       = module.secrets.github_pat_secret_arn
}

output "codepipeline_name" {
  description = "CodePipeline name — DR environment"
  value       = module.cicd.codepipeline_name
}
