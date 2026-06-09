#------------------------------------------------------------------------------
# ANP Streaming AI - Test Outputs
#------------------------------------------------------------------------------

output "api_stage_url" {
  description = "API Gateway base URL for test environment"
  value       = module.api.stage_invoke_url
}

output "api_key_id" {
  description = "API Key ID for POST /classify (test environment)"
  value       = module.api.api_key_id
}

output "catalog_bucket_name" {
  description = "S3 catalog bucket name"
  value       = module.storage.bucket_id
}

output "catalog_table_name" {
  description = "DynamoDB catalog moods table name"
  value       = module.database.catalog_table_name
}

output "user_history_table_name" {
  description = "DynamoDB user history table name"
  value       = module.database.user_history_table_name
}

output "ops_sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications"
  value       = module.monitoring.sns_topic_arn
}

output "classifier_function_name" {
  description = "Classifier Lambda function name"
  value       = module.processing.classifier_function_name
}

output "recommender_function_name" {
  description = "Recommender Lambda function name"
  value       = module.processing.recommender_function_name
}

output "autotagger_function_name" {
  description = "Auto-Tagger Lambda function name"
  value       = module.processing.autotagger_function_name
}
