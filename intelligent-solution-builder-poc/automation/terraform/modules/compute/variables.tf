variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "log_level" {
  description = "Lambda log level"
  type        = string
  default     = "info"
}

variable "app_version" {
  description = "Application version"
  type        = string
  default     = "1.0.0"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 365
}

variable "generation_queue_name" {
  description = "SQS FIFO generation queue name"
  type        = string
}

variable "dlq_name" {
  description = "SQS dead-letter queue name"
  type        = string
}

variable "sqs_message_retention_seconds" {
  description = "SQS message retention in seconds"
  type        = number
  default     = 345600
}

variable "sqs_max_receive_count" {
  description = "Max receive attempts before DLQ routing"
  type        = number
  default     = 3
}

variable "workflow_name" {
  description = "Step Functions state machine name"
  type        = string
}

variable "sfn_max_retry_attempts" {
  description = "Step Functions max retry attempts"
  type        = number
  default     = 3
}

variable "sfn_retry_backoff_rate" {
  description = "Step Functions retry backoff rate"
  type        = number
  default     = 2
}

variable "sfn_retry_interval_seconds" {
  description = "Step Functions retry initial interval"
  type        = number
  default     = 30
}

variable "ecr_repository_prefix" {
  description = "ECR repository name prefix"
  type        = string
  default     = "amatra"
}

variable "ecr_image_tag_mutability" {
  description = "ECR tag mutability: IMMUTABLE or MUTABLE"
  type        = string
  default     = "IMMUTABLE"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Lambda VPC execution"
  type        = list(string)
}

variable "lambda_security_group_id" {
  description = "Lambda security group ID"
  type        = string
}

variable "kms_artifacts_key_arn" {
  description = "KMS artifacts key ARN"
  type        = string
}

variable "kms_database_key_arn" {
  description = "KMS database key ARN"
  type        = string
}

variable "kms_audit_key_arn" {
  description = "KMS audit key ARN"
  type        = string
}

variable "solution_state_table_name" {
  description = "Solution state DynamoDB table name"
  type        = string
}

variable "solution_state_table_arn" {
  description = "Solution state DynamoDB table ARN"
  type        = string
}

variable "usage_tracking_table_name" {
  description = "Usage tracking DynamoDB table name"
  type        = string
}

variable "usage_tracking_table_arn" {
  description = "Usage tracking DynamoDB table ARN"
  type        = string
}

variable "audit_table_name" {
  description = "Audit DynamoDB table name"
  type        = string
}

variable "audit_table_arn" {
  description = "Audit DynamoDB table ARN"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Artifacts S3 bucket name"
  type        = string
}

variable "artifacts_bucket_arn" {
  description = "Artifacts S3 bucket ARN"
  type        = string
}

variable "bedrock_model_id" {
  description = "Bedrock model ID"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

variable "bedrock_region" {
  description = "AWS region for Bedrock API calls"
  type        = string
  default     = "us-west-2"
}

variable "bedrock_max_tokens_per_artifact" {
  description = "Max tokens per Bedrock InvokeModel call"
  type        = number
  default     = 4096
}

variable "presigned_url_expiry_seconds" {
  description = "S3 pre-signed URL expiry in seconds"
  type        = number
  default     = 3600
}

variable "force_destroy" {
  description = "Allow ECR repository deletion even with images"
  type        = bool
  default     = false
}

variable "compute" {
  description = "Lambda compute configuration grouped object"
  type = object({
    architecture                          = string
    brief_submission_memory_mb            = number
    brief_submission_timeout_seconds      = number
    brief_submission_reserved_concurrency = number
    brief_submission_provisioned_concurrency = number
    job_status_memory_mb                  = number
    job_status_timeout_seconds            = number
    job_status_reserved_concurrency       = number
    job_status_provisioned_concurrency    = number
    artifact_retrieval_memory_mb          = number
    artifact_retrieval_timeout_seconds    = number
    artifact_retrieval_reserved_concurrency = number
    admin_governance_memory_mb            = number
    admin_governance_timeout_seconds      = number
    admin_governance_reserved_concurrency = number
    bedrock_orchestration_memory_mb       = number
    bedrock_orchestration_timeout_seconds = number
    bedrock_orchestration_reserved_concurrency = number
    output_validation_memory_mb           = number
    output_validation_timeout_seconds     = number
    output_validation_reserved_concurrency = number
    artifact_template_memory_mb           = number
    artifact_template_timeout_seconds     = number
    artifact_template_reserved_concurrency = number
    ses_notification_memory_mb            = number
    ses_notification_timeout_seconds      = number
    health_check_memory_mb                = number
  })
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
