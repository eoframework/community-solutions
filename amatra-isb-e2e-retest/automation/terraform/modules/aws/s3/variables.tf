variable "bucket_name" {
  description = "S3 bucket name (must be globally unique)"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for SSE-KMS encryption (empty string for SSE-S3)"
  type        = string
  default     = ""
}

variable "lifecycle_rules_enabled" {
  description = "Enable lifecycle rules for tiered storage"
  type        = bool
  default     = true
}

variable "standard_retention_days" {
  description = "Days in S3 Standard storage before transitioning to Glacier"
  type        = number
  default     = 365
}

variable "glacier_retention_days" {
  description = "Days in S3 Glacier before expiry"
  type        = number
  default     = 730
}

variable "force_destroy" {
  description = "Allow destroying non-empty bucket"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
