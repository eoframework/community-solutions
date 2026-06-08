#------------------------------------------------------------------------------
# ANP Streaming AI Recommendation Engine — DR Outputs
#------------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC identifier for the DR environment"
  value       = module.networking.vpc_id
}

output "api_gateway_endpoint" {
  description = "Base URL of the DR API Gateway endpoint (activated on failover)"
  value       = module.api_service.api_gateway_endpoint
}

output "api_gateway_id" {
  description = "API Gateway REST API identifier"
  value       = module.api_service.api_gateway_id
}

output "api_gateway_stage_arn" {
  description = "ARN of the deployed API Gateway stage"
  value       = module.api_service.api_gateway_stage_arn
}

output "cognito_user_pool_id_ssm_param" {
  description = "SSM Parameter Store path containing the Cognito User Pool ID"
  value       = module.security.cognito_user_pool_id_ssm_param
}

output "catalog_kms_key_arn" {
  description = "KMS key ARN for catalog data encryption"
  value       = module.security.catalog_kms_key_arn
}

output "user_data_kms_key_arn" {
  description = "KMS key ARN for user data encryption"
  value       = module.security.user_data_kms_key_arn
}

output "model_kms_key_arn" {
  description = "KMS key ARN for SageMaker model artifact encryption"
  value       = module.security.model_kms_key_arn
}

output "feedback_queue_url" {
  description = "SQS URL for the feedback capture queue"
  value       = module.messaging.feedback_queue_url
}

output "feedback_queue_arn" {
  description = "SQS ARN for the feedback capture queue"
  value       = module.messaging.feedback_queue_arn
}

output "feedback_dlq_name" {
  description = "SQS Dead Letter Queue name for failed feedback events"
  value       = module.messaging.feedback_dlq_name
}

output "catalog_event_bus_arn" {
  description = "EventBridge custom bus ARN for catalog upload events"
  value       = module.messaging.catalog_event_bus_arn
}

output "sns_alert_topic_arn" {
  description = "SNS topic ARN for operational alerts"
  value       = module.monitoring.sns_topic_arn
}

output "opensearch_endpoint" {
  description = "OpenSearch Service domain endpoint"
  value       = module.opensearch.endpoint
}

output "cache_endpoint" {
  description = "ElastiCache Redis primary endpoint (empty when cache is disabled)"
  value       = var.cache.enabled ? module.cache[0].primary_endpoint : null
}

output "private_subnet_app_ids" {
  description = "IDs of the private application subnets"
  value       = module.networking.private_subnet_app_ids
}

output "content_catalog_table_arn" {
  description = "DynamoDB table ARN for the enriched content catalog"
  value       = module.database.content_catalog_table_arn
}

output "user_profile_table_arn" {
  description = "DynamoDB table ARN for user preference vectors"
  value       = module.database.user_profile_table_arn
}

output "raw_catalog_bucket_name" {
  description = "S3 bucket name for source audio and catalog files"
  value       = module.storage.raw_catalog_bucket_name
}

output "models_bucket_name" {
  description = "S3 bucket name for SageMaker model artifacts"
  value       = module.storage.models_bucket_name
}
