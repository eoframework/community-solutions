variable "bucket_name" {
  description = "S3 bucket name (globally unique)"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS CMK ARN for SSE-KMS encryption"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "List of lifecycle rule configurations"
  type        = any
  default     = []
}

variable "enable_object_lock" {
  description = "Enable S3 Object Lock (WORM)"
  type        = bool
  default     = false
}

variable "object_lock_mode" {
  description = "Object Lock retention mode (COMPLIANCE or GOVERNANCE)"
  type        = string
  default     = "COMPLIANCE"
}

variable "object_lock_years" {
  description = "Object Lock default retention period in years"
  type        = number
  default     = 7
}

variable "force_destroy" {
  description = "Allow bucket deletion even if non-empty (false for production)"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
