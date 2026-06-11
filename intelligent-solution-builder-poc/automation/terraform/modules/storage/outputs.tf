output "artifacts_bucket_id" {
  description = "Artifacts S3 bucket name"
  value       = module.s3_artifacts.bucket_id
}

output "artifacts_bucket_arn" {
  description = "Artifacts S3 bucket ARN"
  value       = module.s3_artifacts.bucket_arn
}

output "terraform_state_bucket_id" {
  description = "Terraform state S3 bucket name"
  value       = module.s3_terraform_state.bucket_id
}

output "solution_state_table_name" {
  description = "Solution state DynamoDB table name"
  value       = module.dynamodb_solution_state.table_name
}

output "solution_state_table_arn" {
  description = "Solution state DynamoDB table ARN"
  value       = module.dynamodb_solution_state.table_arn
}

output "usage_tracking_table_name" {
  description = "Usage tracking DynamoDB table name"
  value       = module.dynamodb_usage_tracking.table_name
}

output "usage_tracking_table_arn" {
  description = "Usage tracking DynamoDB table ARN"
  value       = module.dynamodb_usage_tracking.table_arn
}

output "audit_table_name" {
  description = "Audit DynamoDB table name"
  value       = module.dynamodb_audit.table_name
}

output "audit_table_arn" {
  description = "Audit DynamoDB table ARN"
  value       = module.dynamodb_audit.table_arn
}

output "terraform_lock_table_name" {
  description = "Terraform lock DynamoDB table name"
  value       = module.dynamodb_terraform_lock.table_name
}
