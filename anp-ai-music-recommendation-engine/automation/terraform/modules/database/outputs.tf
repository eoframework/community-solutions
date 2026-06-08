output "content_catalog_table_name" {
  description = "DynamoDB table name for content catalog"
  value       = module.content_catalog.table_name
}

output "content_catalog_table_arn" {
  description = "DynamoDB table ARN for content catalog"
  value       = module.content_catalog.table_arn
}

output "user_profile_table_name" {
  description = "DynamoDB table name for user profiles"
  value       = module.user_profiles.table_name
}

output "user_profile_table_arn" {
  description = "DynamoDB table ARN for user profiles"
  value       = module.user_profiles.table_arn
}

output "interaction_events_table_name" {
  description = "DynamoDB table name for interaction events"
  value       = module.interaction_events.table_name
}

output "interaction_events_table_arn" {
  description = "DynamoDB table ARN for interaction events"
  value       = module.interaction_events.table_arn
}

output "mood_taxonomy_table_name" {
  description = "DynamoDB table name for mood taxonomy"
  value       = module.mood_taxonomy.table_name
}

output "mood_taxonomy_table_arn" {
  description = "DynamoDB table ARN for mood taxonomy"
  value       = module.mood_taxonomy.table_arn
}
