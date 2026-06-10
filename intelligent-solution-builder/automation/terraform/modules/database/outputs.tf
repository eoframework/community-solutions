output "solution_state_table_name" {
  description = "DynamoDB solution state table name"
  value       = module.solution_state_table.table_name
}

output "solution_state_table_arn" {
  description = "DynamoDB solution state table ARN"
  value       = module.solution_state_table.table_arn
}

output "usage_tracking_table_name" {
  description = "DynamoDB usage tracking table name"
  value       = module.usage_tracking_table.table_name
}

output "usage_tracking_table_arn" {
  description = "DynamoDB usage tracking table ARN"
  value       = module.usage_tracking_table.table_arn
}
