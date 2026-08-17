variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail log delivery"
  type        = string
}

variable "s3_key_prefix" {
  description = "S3 key prefix for CloudTrail logs"
  type        = string
  default     = ""
}

variable "is_organization_trail" {
  description = "Create an organisation-wide trail"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudTrail encryption. Null uses SSE-S3."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_arn" {
  description = "CloudWatch Log Group ARN for CloudTrail delivery"
  type        = string
  default     = null
}

variable "cloudwatch_log_role_arn" {
  description = "IAM role ARN for CloudTrail to deliver to CloudWatch"
  type        = string
  default     = null
}

variable "enable_data_events" {
  description = "Enable S3 data event recording"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
