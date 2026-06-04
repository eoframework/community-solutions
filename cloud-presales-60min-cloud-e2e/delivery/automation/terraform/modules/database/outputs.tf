output "users_table_name" {
  description = "DynamoDB Users table name"
  value       = module.users_table.table_name
}

output "users_table_arn" {
  description = "DynamoDB Users table ARN"
  value       = module.users_table.table_arn
}

output "solutions_table_name" {
  description = "DynamoDB Solutions table name"
  value       = module.solutions_table.table_name
}

output "solutions_table_arn" {
  description = "DynamoDB Solutions table ARN"
  value       = module.solutions_table.table_arn
}

output "global_quota_table_name" {
  description = "DynamoDB GlobalQuota table name"
  value       = module.global_quota_table.table_name
}

output "global_quota_table_arn" {
  description = "DynamoDB GlobalQuota table ARN"
  value       = module.global_quota_table.table_arn
}
