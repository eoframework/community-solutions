#------------------------------------------------------------------------------
# Processing Module (Tier 2) - Variables
#------------------------------------------------------------------------------

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "log_level" {
  description = "Lambda log level (debug|info|warn|error)"
  type        = string
  default     = "info"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "enable_xray" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log group retention days"
  type        = number
  default     = 90
}

variable "mood_labels" {
  description = "Comma-separated mood label vocabulary"
  type        = string
  default     = "Joyful,Reflective,Peaceful,Uplifting,Worshipful,Hopeful"
}

variable "bedrock_max_tokens" {
  description = "Max tokens for Bedrock InvokeModel responses"
  type        = number
  default     = 512
}

variable "min_confidence_threshold" {
  description = "Minimum confidence score for mood tags"
  type        = string
  default     = "0.5"
}

# Classifier
variable "classifier_function_name" {
  description = "Classifier Lambda function name"
  type        = string
}

variable "classifier_memory_mb" {
  description = "Classifier Lambda memory in MB"
  type        = number
  default     = 1024
}

variable "classifier_timeout_seconds" {
  description = "Classifier Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "classifier_policy_arn" {
  description = "IAM policy ARN to attach to Classifier Lambda role"
  type        = string
  default     = ""
}

variable "classifier_policy_json" {
  description = "Inline IAM policy JSON for Classifier Lambda"
  type        = string
  default     = ""
}

# Recommender
variable "recommender_function_name" {
  description = "Recommender Lambda function name"
  type        = string
}

variable "recommender_memory_mb" {
  description = "Recommender Lambda memory in MB"
  type        = number
  default     = 512
}

variable "recommender_timeout_seconds" {
  description = "Recommender Lambda timeout in seconds"
  type        = number
  default     = 15
}

variable "recommender_policy_arn" {
  description = "IAM policy ARN to attach to Recommender Lambda role"
  type        = string
  default     = ""
}

variable "recommender_policy_json" {
  description = "Inline IAM policy JSON for Recommender Lambda"
  type        = string
  default     = ""
}

variable "catalog_table_name" {
  description = "DynamoDB catalog moods table name"
  type        = string
}

variable "user_history_table_name" {
  description = "DynamoDB user history table name"
  type        = string
}

variable "catalog_gsi_name" {
  description = "Catalog mood-label GSI name"
  type        = string
  default     = "mood_label-index"
}

variable "history_lookback" {
  description = "Number of recent history records to fetch per user"
  type        = number
  default     = 20
}

variable "recommend_default_limit" {
  description = "Default playlist item count"
  type        = number
  default     = 10
}

variable "recommend_max_limit" {
  description = "Max playlist item count"
  type        = number
  default     = 50
}

# Auto-Tagger
variable "autotagger_function_name" {
  description = "Auto-Tagger Lambda function name"
  type        = string
}

variable "autotagger_dlq_name" {
  description = "Auto-Tagger DLQ name"
  type        = string
}

variable "autotagger_memory_mb" {
  description = "Auto-Tagger Lambda memory in MB"
  type        = number
  default     = 512
}

variable "autotagger_timeout_seconds" {
  description = "Auto-Tagger Lambda timeout in seconds"
  type        = number
  default     = 60
}

variable "autotagger_max_retries" {
  description = "Max Bedrock retries inside Auto-Tagger Lambda"
  type        = number
  default     = 3
}

variable "autotagger_policy_arn" {
  description = "IAM policy ARN to attach to Auto-Tagger Lambda role"
  type        = string
  default     = ""
}

variable "autotagger_policy_json" {
  description = "Inline IAM policy JSON for Auto-Tagger Lambda"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
