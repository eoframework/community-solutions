variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda runtime (Python version)"
  type        = string
  default     = "python3.12"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "solution_create_memory_mb" {
  description = "Solution Create Lambda memory in MB"
  type        = number
  default     = 512
}

variable "solution_create_timeout_seconds" {
  description = "Solution Create Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "solution_create_concurrency_limit" {
  description = "Solution Create Lambda reserved concurrency"
  type        = number
  default     = 50
}

variable "solution_create_provisioned_concurrency" {
  description = "Solution Create Lambda provisioned concurrency instances"
  type        = number
  default     = 0
}

variable "status_memory_mb" {
  description = "Status Lambda memory in MB"
  type        = number
  default     = 256
}

variable "status_timeout_seconds" {
  description = "Status Lambda timeout in seconds"
  type        = number
  default     = 10
}

variable "artifact_fetch_memory_mb" {
  description = "Artifact Fetch Lambda memory in MB"
  type        = number
  default     = 256
}

variable "artifact_fetch_timeout_seconds" {
  description = "Artifact Fetch Lambda timeout in seconds"
  type        = number
  default     = 10
}

variable "admin_usage_memory_mb" {
  description = "Admin Usage Lambda memory in MB"
  type        = number
  default     = 256
}

variable "admin_usage_timeout_seconds" {
  description = "Admin Usage Lambda timeout in seconds"
  type        = number
  default     = 15
}

variable "github_integration_memory_mb" {
  description = "GitHub Integration Lambda memory in MB"
  type        = number
  default     = 512
}

variable "github_integration_timeout_seconds" {
  description = "GitHub Integration Lambda timeout in seconds"
  type        = number
  default     = 60
}

variable "github_integration_concurrency_limit" {
  description = "GitHub Integration Lambda reserved concurrency"
  type        = number
  default     = 20
}

variable "post_confirmation_memory_mb" {
  description = "Post-Confirmation Lambda memory in MB"
  type        = number
  default     = 256
}

variable "post_confirmation_timeout_seconds" {
  description = "Post-Confirmation Lambda timeout in seconds"
  type        = number
  default     = 15
}

variable "xray_tracing_enabled" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 30
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "info"
}

variable "application_name" {
  description = "Application name for structured logging"
  type        = string
}

variable "application_version" {
  description = "Application version for structured logging"
  type        = string
}

variable "github_pat_secret_name" {
  description = "Secrets Manager secret name for GitHub PAT"
  type        = string
}

variable "github_repository_url" {
  description = "GitHub repository URL for artifact commits"
  type        = string
}

variable "github_commit_retry_count" {
  description = "Maximum GitHub commit retry attempts"
  type        = number
  default     = 3
}

variable "github_branch" {
  description = "GitHub target branch for artifact commits"
  type        = string
  default     = "main"
}

variable "bedrock_generation_model_id" {
  description = "Bedrock model ID for artifact generation"
  type        = string
}

variable "bedrock_validation_model_id" {
  description = "Bedrock model ID for artifact validation"
  type        = string
}

variable "bedrock_max_retries" {
  description = "Maximum Bedrock retry attempts per artifact"
  type        = number
  default     = 3
}

variable "bedrock_retry_initial_delay_ms" {
  description = "Initial backoff delay in ms for Bedrock retries"
  type        = number
  default     = 1000
}

variable "users_table_name" {
  description = "DynamoDB Users table name"
  type        = string
}

variable "solutions_table_name" {
  description = "DynamoDB Solutions table name"
  type        = string
}

variable "global_quota_table_name" {
  description = "DynamoDB GlobalQuota table name"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "S3 artifacts bucket name"
  type        = string
}

variable "artifacts_prefix_raw" {
  description = "S3 prefix for raw artifacts"
  type        = string
  default     = "raw/"
}

variable "artifacts_prefix_converted" {
  description = "S3 prefix for converted artifacts"
  type        = string
  default     = "converted/"
}

variable "terraform_prefix" {
  description = "S3 prefix for Terraform bundles"
  type        = string
  default     = "terraform/"
}

variable "user_monthly_solution_limit" {
  description = "Per-user monthly solution limit"
  type        = number
  default     = 10
}

variable "global_monthly_solution_limit" {
  description = "Global monthly solution limit"
  type        = number
  default     = 1000
}

variable "ssm_s3_artifacts_bucket_param" {
  description = "SSM parameter path for S3 artifacts bucket name"
  type        = string
}

variable "ssm_dynamodb_solutions_table_param" {
  description = "SSM parameter path for DynamoDB solutions table name"
  type        = string
}

variable "solution_create_role_arn" {
  description = "IAM role ARN for Solution Create Lambda"
  type        = string
}

variable "status_role_arn" {
  description = "IAM role ARN for Status Lambda"
  type        = string
}

variable "artifact_fetch_role_arn" {
  description = "IAM role ARN for Artifact Fetch Lambda"
  type        = string
}

variable "admin_usage_role_arn" {
  description = "IAM role ARN for Admin Usage Lambda"
  type        = string
}

variable "github_integration_role_arn" {
  description = "IAM role ARN for GitHub Integration Lambda"
  type        = string
}

variable "post_confirmation_role_arn" {
  description = "IAM role ARN for Post-Confirmation Lambda"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
