variable "name_prefix" {
  description = "Naming prefix for compute resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (prod, test, dr)"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "aws_region" {
  description = "AWS region for IAM policy ARN construction"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime (python3.12)"
  type        = string
  default     = "python3.12"
}

variable "lambda_alias" {
  description = "Lambda alias name for blue-green deployments"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 30
}

variable "log_level" {
  description = "Lambda application log level"
  type        = string
  default     = "info"
}

variable "secret_prefix" {
  description = "Secrets Manager path prefix (e.g. amatra/prod)"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for Lambda log group encryption and Secrets Manager access"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "S3 artifacts bucket name"
  type        = string
}

variable "templates_bucket_name" {
  description = "S3 templates bucket name"
  type        = string
}

variable "solution_state_table_name" {
  description = "DynamoDB solution state table name"
  type        = string
}

variable "usage_tracking_table_name" {
  description = "DynamoDB usage tracking table name"
  type        = string
}

variable "job_queue_arn" {
  description = "SQS job queue ARN"
  type        = string
}

variable "job_queue_url" {
  description = "SQS job queue URL"
  type        = string
}

variable "state_machine_name" {
  description = "Step Functions state machine name"
  type        = string
}

variable "sonnet_model_id" {
  description = "Amazon Bedrock Claude 3 Sonnet model ID"
  type        = string
}

variable "haiku_model_id" {
  description = "Amazon Bedrock Claude 3 Haiku model ID"
  type        = string
}

variable "api_submit_memory" {
  description = "Memory for api-submit Lambda (MB)"
  type        = number
  default     = 512
}

variable "api_submit_timeout" {
  description = "Timeout for api-submit Lambda (seconds)"
  type        = number
  default     = 30
}

variable "api_submit_provisioned" {
  description = "Provisioned concurrency for api-submit Lambda"
  type        = number
  default     = 0
}

variable "api_status_memory" {
  description = "Memory for api-status Lambda (MB)"
  type        = number
  default     = 256
}

variable "api_status_timeout" {
  description = "Timeout for api-status Lambda (seconds)"
  type        = number
  default     = 10
}

variable "api_status_provisioned" {
  description = "Provisioned concurrency for api-status Lambda"
  type        = number
  default     = 0
}

variable "api_retrieve_memory" {
  description = "Memory for api-retrieve Lambda (MB)"
  type        = number
  default     = 256
}

variable "api_retrieve_timeout" {
  description = "Timeout for api-retrieve Lambda (seconds)"
  type        = number
  default     = 10
}

variable "api_retrieve_provisioned" {
  description = "Provisioned concurrency for api-retrieve Lambda"
  type        = number
  default     = 0
}

variable "api_admin_memory" {
  description = "Memory for api-admin Lambda (MB)"
  type        = number
  default     = 256
}

variable "api_admin_timeout" {
  description = "Timeout for api-admin Lambda (seconds)"
  type        = number
  default     = 30
}

variable "api_admin_provisioned" {
  description = "Provisioned concurrency for api-admin Lambda"
  type        = number
  default     = 0
}

variable "orchestrator_memory" {
  description = "Memory for orchestrator-start Lambda (MB)"
  type        = number
  default     = 512
}

variable "orchestrator_timeout" {
  description = "Timeout for orchestrator-start Lambda (seconds)"
  type        = number
  default     = 60
}

variable "bedrock_sonnet_memory" {
  description = "Memory for bedrock-sonnet Lambda (MB)"
  type        = number
  default     = 1024
}

variable "bedrock_sonnet_timeout" {
  description = "Timeout for bedrock-sonnet Lambda (seconds)"
  type        = number
  default     = 900
}

variable "bedrock_haiku_memory" {
  description = "Memory for bedrock-haiku Lambda (MB)"
  type        = number
  default     = 512
}

variable "bedrock_haiku_timeout" {
  description = "Timeout for bedrock-haiku Lambda (seconds)"
  type        = number
  default     = 600
}

variable "artifact_processor_memory" {
  description = "Memory for artifact-processor Lambda (MB)"
  type        = number
  default     = 512
}

variable "artifact_processor_timeout" {
  description = "Timeout for artifact-processor Lambda (seconds)"
  type        = number
  default     = 300
}

variable "reserved_concurrency_total" {
  description = "Total reserved concurrency across all platform Lambda functions"
  type        = number
  default     = 500
}

variable "presigned_url_ttl_seconds" {
  description = "S3 presigned URL expiry in seconds"
  type        = number
  default     = 86400
}

variable "per_user_monthly_limit" {
  description = "Default per-user monthly generation limit"
  type        = number
  default     = 10
}

variable "global_monthly_limit" {
  description = "Default global monthly generation limit"
  type        = number
  default     = 240
}
