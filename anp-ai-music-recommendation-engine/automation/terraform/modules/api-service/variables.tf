variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "api_version" {
  description = "API version path prefix (e.g. v1)"
  type        = string
  default     = "v1"
}

variable "apigw_stage_name" {
  description = "API Gateway stage name"
  type        = string
}

variable "apigw_integration_timeout_ms" {
  description = "API Gateway backend integration timeout in milliseconds"
  type        = number
  default     = 29000
}

variable "apigw_rate_limit_rps" {
  description = "API Gateway usage-plan requests per second"
  type        = number
  default     = 100
}

variable "lambda_architecture" {
  description = "Lambda CPU architecture (arm64 or x86_64)"
  type        = string
  default     = "arm64"
}

variable "lambda_playlist_memory_mb" {
  description = "Memory for the Playlist Generation Lambda"
  type        = number
  default     = 1024
}

variable "lambda_playlist_timeout_seconds" {
  description = "Timeout for the Playlist Lambda"
  type        = number
  default     = 29
}

variable "lambda_enrichment_memory_mb" {
  description = "Memory for the Catalog Enrichment Lambda"
  type        = number
  default     = 512
}

variable "lambda_enrichment_timeout_seconds" {
  description = "Timeout for the Catalog Enrichment Lambda"
  type        = number
  default     = 300
}

variable "lambda_authorizer_memory_mb" {
  description = "Memory for the API Gateway Lambda Authorizer"
  type        = number
  default     = 256
}

variable "lambda_authorizer_timeout_seconds" {
  description = "Timeout for the Lambda Authorizer"
  type        = number
  default     = 5
}

variable "lambda_feedback_memory_mb" {
  description = "Memory for the Feedback Capture Lambda"
  type        = number
  default     = 256
}

variable "lambda_preference_update_memory_mb" {
  description = "Memory for the Preference Update Lambda"
  type        = number
  default     = 512
}

variable "lambda_max_concurrency" {
  description = "Maximum reserved concurrent Lambda executions"
  type        = number
  default     = 100
}

variable "log_level" {
  description = "Lambda function log level"
  type        = string
  default     = "info"
}

variable "playlist_count_default" {
  description = "Default track count for playlist generation"
  type        = number
  default     = 20
}

variable "cold_start_threshold" {
  description = "Minimum interactions before using Personalize vs cold-start fallback"
  type        = number
  default     = 10
}

variable "xray_tracing_enabled" {
  description = "Enable AWS X-Ray active tracing"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 90
}

variable "firebase_api_url" {
  description = "Firebase REST API base URL"
  type        = string
}

variable "firebase_timeout_ms" {
  description = "Firebase REST API call timeout in milliseconds"
  type        = number
  default     = 30000
}

variable "bedrock_model_id" {
  description = "Bedrock foundation model ID for fallback enrichment"
  type        = string
}

variable "bedrock_max_tokens" {
  description = "Maximum token count for Bedrock inference"
  type        = number
  default     = 512
}

variable "cognito_user_pool_id_param" {
  description = "SSM parameter name containing the Cognito User Pool ID"
  type        = string
}

variable "catalog_kms_key_arn" {
  description = "KMS key ARN for catalog data encryption"
  type        = string
}

variable "user_data_kms_key_arn" {
  description = "KMS key ARN for user data encryption"
  type        = string
}

variable "content_catalog_table_name" {
  description = "DynamoDB table name for content catalog"
  type        = string
}

variable "user_profile_table_name" {
  description = "DynamoDB table name for user profiles"
  type        = string
}

variable "interaction_events_table_name" {
  description = "DynamoDB table name for interaction events"
  type        = string
}

variable "mood_taxonomy_table_name" {
  description = "DynamoDB table name for mood taxonomy"
  type        = string
}

variable "feedback_queue_arn" {
  description = "SQS feedback queue ARN"
  type        = string
}

variable "feedback_queue_url" {
  description = "SQS feedback queue URL"
  type        = string
}

variable "catalog_event_bus_name" {
  description = "EventBridge catalog custom bus name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Lambda ENI placement"
  type        = string
}

variable "private_subnet_app_ids" {
  description = "Private application subnet IDs for Lambda ENIs"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group ID for Lambda functions"
  type        = string
}

variable "waf_web_acl_arn" {
  description = "WAF Web ACL ARN (null if WAF is disabled)"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
