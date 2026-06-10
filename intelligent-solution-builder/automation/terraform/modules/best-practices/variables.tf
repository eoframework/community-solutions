variable "name_prefix" {
  description = "Naming prefix for best-practices resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail for audit logging"
  type        = bool
  default     = true
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "cloudtrail_kms_key_arn" {
  description = "KMS CMK ARN for CloudTrail encryption"
  type        = string
  default     = null
}

variable "enable_config_rules" {
  description = "Enable AWS Config compliance rules"
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for Config rule non-compliance notifications"
  type        = string
}

variable "cognito_export_schedule" {
  description = "EventBridge cron expression for nightly Cognito export"
  type        = string
  default     = "cron(0 2 * * ? *)"
}

variable "artifacts_bucket_name" {
  description = "S3 artifacts bucket name for Cognito export destination"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for Cognito export encryption"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID for export Lambda"
  type        = string
}
