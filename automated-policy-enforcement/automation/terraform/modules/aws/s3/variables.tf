variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "purpose" {
  description = "Short purpose label appended to the bucket name"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS CMK for SSE-KMS encryption"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable S3 versioning"
  type        = bool
  default     = true
}

variable "object_lock_enabled" {
  description = "Enable S3 Object Lock (WORM) — must be set at bucket creation"
  type        = bool
  default     = false
}

variable "object_lock_mode" {
  description = "S3 Object Lock retention mode (COMPLIANCE or GOVERNANCE)"
  type        = string
  default     = "COMPLIANCE"
}

variable "object_lock_years" {
  description = "Object Lock default retention period in years"
  type        = number
  default     = 1
}

variable "force_destroy" {
  description = "Allow bucket destruction even if not empty (use false for log archive buckets)"
  type        = bool
  default     = false
}

variable "replication_enabled" {
  description = "Whether cross-region replication is configured for this bucket (informational)"
  type        = bool
  default     = false
}

variable "replication_region" {
  description = "Target region for S3 CRR (used for documentation; actual CRR configured in storage module)"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
