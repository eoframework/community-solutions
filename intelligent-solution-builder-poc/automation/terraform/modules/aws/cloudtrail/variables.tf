variable "trail_name" {
  description = "CloudTrail trail name"
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudTrail log encryption"
  type        = string
}

variable "include_data_events" {
  description = "Enable S3 object-level and DynamoDB data events"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow bucket deletion even if not empty (test only)"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
