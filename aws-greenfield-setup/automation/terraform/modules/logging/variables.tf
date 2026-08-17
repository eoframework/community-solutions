variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "log_archive_bucket_name" {
  description = "Name of the Log Archive S3 bucket"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption. Null uses SSE-S3."
  type        = string
  default     = null
}

variable "object_lock_enabled" {
  description = "Enable S3 Object Lock on the Log Archive bucket"
  type        = bool
  default     = true
}

variable "object_lock_retention_days" {
  description = "Object Lock compliance retention period in days"
  type        = number
  default     = 90
}

variable "glacier_transition_days" {
  description = "Days before transitioning logs to Glacier Instant Retrieval"
  type        = number
  default     = 90
}

variable "log_archive_bucket_policy" {
  description = "JSON bucket policy for the Log Archive bucket"
  type        = string
  default     = null
}

variable "trail_name" {
  description = "Name of the CloudTrail organization trail"
  type        = string
}

variable "is_organization_trail" {
  description = "Whether this is an organization-wide trail"
  type        = bool
  default     = true
}

variable "enable_cloudtrail_data_events" {
  description = "Enable S3 data events in CloudTrail"
  type        = bool
  default     = false
}

variable "enable_cloudtrail_lake" {
  description = "Enable CloudTrail Lake event data store"
  type        = bool
  default     = true
}

variable "cloudtrail_lake_retention_days" {
  description = "Retention period in days for CloudTrail Lake (365 days per year)"
  type        = number
  default     = 2557
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
