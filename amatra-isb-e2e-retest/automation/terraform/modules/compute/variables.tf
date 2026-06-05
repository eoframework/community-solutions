variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "info"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
}

variable "vpc_id" {
  description = "VPC ID for Lambda VPC attachment"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Lambda"
  type        = list(string)
}

variable "compute" {
  description = "Compute configuration object"
  type = object({
    ecr_repository_name                = string
    ecr_agent_image_uri                = string
    lambda_runtime                     = string
    lambda_architecture                = string
    xray_tracing                       = string
    api_handler_memory_mb              = number
    api_handler_timeout_seconds        = number
    generation_initiator_memory_mb     = number
    generation_initiator_timeout_seconds = number
    agent_trigger_memory_mb            = number
    agent_trigger_timeout_seconds      = number
    cognito_trigger_memory_mb          = number
    cognito_trigger_timeout_seconds    = number
    github_push_memory_mb              = number
    github_push_timeout_seconds        = number
  })
}

variable "bedrock_region" {
  description = "AWS region for Bedrock AgentCore Runtime"
  type        = string
}

variable "bedrock_primary_model_id" {
  description = "Bedrock primary model ID for artifact generation"
  type        = string
}

variable "bedrock_validator_model_id" {
  description = "Bedrock validator model ID for quality scoring"
  type        = string
}

variable "users_table_name" {
  description = "Users DynamoDB table name"
  type        = string
}

variable "solutions_table_name" {
  description = "Solutions DynamoDB table name"
  type        = string
}

variable "quotas_table_name" {
  description = "Quotas DynamoDB table name"
  type        = string
}

variable "audit_events_table_name" {
  description = "Audit events DynamoDB table name"
  type        = string
}

variable "dynamodb_table_arns" {
  description = "List of all DynamoDB table ARNs for IAM policy"
  type        = list(string)
}

variable "artifact_bucket_name" {
  description = "Artifact S3 bucket name"
  type        = string
}

variable "artifact_bucket_arn" {
  description = "Artifact S3 bucket ARN"
  type        = string
}

variable "guidance_bucket_name" {
  description = "Guidance S3 bucket name"
  type        = string
}

variable "guidance_bucket_arn" {
  description = "Guidance S3 bucket ARN"
  type        = string
}

variable "github_secret_arn" {
  description = "Secrets Manager ARN for GitHub PAT"
  type        = string
}

variable "github_dlq_url" {
  description = "SQS DLQ URL for failed GitHub push messages"
  type        = string
}

variable "github_dlq_arn" {
  description = "SQS DLQ ARN for failed GitHub push messages"
  type        = string
}

variable "github_push_retry_count" {
  description = "Maximum GitHub push retry attempts"
  type        = number
  default     = 3
}

variable "quota_per_user_monthly" {
  description = "Per-user monthly solution quota"
  type        = number
  default     = 10
}

variable "quota_global_monthly" {
  description = "Global monthly solution quota"
  type        = number
  default     = 1000
}

variable "max_retries_per_artifact" {
  description = "Maximum automatic retries per artifact"
  type        = number
  default     = 3
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
