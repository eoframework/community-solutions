output "users_table_name" {
  description = "Users DynamoDB table name"
  value       = module.users_table.table_name
}

output "users_table_arn" {
  description = "Users DynamoDB table ARN"
  value       = module.users_table.table_arn
}

output "solutions_table_name" {
  description = "Solutions DynamoDB table name"
  value       = module.solutions_table.table_name
}

output "solutions_table_arn" {
  description = "Solutions DynamoDB table ARN"
  value       = module.solutions_table.table_arn
}

output "quotas_table_name" {
  description = "Quotas DynamoDB table name"
  value       = module.quotas_table.table_name
}

output "quotas_table_arn" {
  description = "Quotas DynamoDB table ARN"
  value       = module.quotas_table.table_arn
}

output "audit_events_table_name" {
  description = "Audit events DynamoDB table name"
  value       = module.audit_events_table.table_name
}

output "audit_events_table_arn" {
  description = "Audit events DynamoDB table ARN"
  value       = module.audit_events_table.table_arn
}
