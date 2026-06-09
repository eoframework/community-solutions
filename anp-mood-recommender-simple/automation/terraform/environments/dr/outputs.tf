#------------------------------------------------------------------------------
# ANP Streaming AI - DR Outputs
#------------------------------------------------------------------------------

output "api_stage_url" {
  description = "DR API Gateway base URL"
  value       = module.api.stage_invoke_url
}

output "api_key_id" {
  description = "DR API Key ID for POST /classify"
  value       = module.api.api_key_id
}

output "catalog_bucket_name" {
  description = "DR S3 catalog bucket name"
  value       = module.storage.bucket_id
}

output "catalog_table_name" {
  description = "DR DynamoDB catalog moods table name"
  value       = module.database.catalog_table_name
}

output "user_history_table_name" {
  description = "DR DynamoDB user history table name"
  value       = module.database.user_history_table_name
}

output "ops_sns_topic_arn" {
  description = "DR SNS topic ARN for CloudWatch alarm notifications"
  value       = module.monitoring.sns_topic_arn
}

output "classifier_function_name" {
  description = "DR Classifier Lambda function name"
  value       = module.processing.classifier_function_name
}

output "recommender_function_name" {
  description = "DR Recommender Lambda function name"
  value       = module.processing.recommender_function_name
}

output "autotagger_function_name" {
  description = "DR Auto-Tagger Lambda function name"
  value       = module.processing.autotagger_function_name
}

output "autotagger_dlq_arn" {
  description = "DR Auto-Tagger DLQ ARN"
  value       = module.processing.autotagger_dlq_arn
}
