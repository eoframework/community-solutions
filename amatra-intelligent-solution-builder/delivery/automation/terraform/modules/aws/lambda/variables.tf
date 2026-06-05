variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "memory_mb" {
  description = "Lambda memory allocation in MB"
  type        = number
  default     = 1024
}

variable "timeout_seconds" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 900
}

variable "reserved_concurrency" {
  description = "Reserved concurrency units"
  type        = number
  default     = 50
}

variable "ecr_repository_url" {
  description = "ECR repository URL for container image"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Lambda VPC attachment"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Lambda VPC attachment"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudWatch Logs encryption"
  type        = string
}

variable "table_user_profiles_name" {
  description = "DynamoDB user profiles table name"
  type        = string
}

variable "table_solution_state_name" {
  description = "DynamoDB solution state table name"
  type        = string
}

variable "table_quota_global_name" {
  description = "DynamoDB global quota table name"
  type        = string
}

variable "artifact_bucket_name" {
  description = "S3 artifact bucket name"
  type        = string
}

variable "github_pat_secret_arn" {
  description = "Secrets Manager ARN for GitHub PAT"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
}

variable "log_level" {
  description = "Logging verbosity level"
  type        = string
  default     = "info"
}

variable "validation_retry_limit" {
  description = "Maximum per-artifact validation retry attempts"
  type        = number
  default     = 3
}

variable "generation_timeout_minutes" {
  description = "P95 end-to-end solution generation SLA in minutes"
  type        = number
  default     = 60
}

variable "quota_reset_schedule" {
  description = "EventBridge cron expression for monthly quota reset"
  type        = string
  default     = "cron(0 0 1 * ? *)"
}

variable "metrics_namespace" {
  description = "CloudWatch custom metrics namespace"
  type        = string
  default     = "AmatraPlatform"
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
