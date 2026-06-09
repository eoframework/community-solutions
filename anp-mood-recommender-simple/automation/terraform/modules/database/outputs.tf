#------------------------------------------------------------------------------
# Database Module (Tier 2) - Outputs
#------------------------------------------------------------------------------

output "catalog_table_name" {
  description = "Catalog moods DynamoDB table name"
  value       = module.catalog_moods.table_name
}

output "catalog_table_arn" {
  description = "Catalog moods DynamoDB table ARN"
  value       = module.catalog_moods.table_arn
}

output "user_history_table_name" {
  description = "User history DynamoDB table name"
  value       = module.user_history.table_name
}

output "user_history_table_arn" {
  description = "User history DynamoDB table ARN"
  value       = module.user_history.table_arn
}
