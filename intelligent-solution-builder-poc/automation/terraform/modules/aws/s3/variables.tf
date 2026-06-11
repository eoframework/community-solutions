variable "bucket_name" {
  description = "S3 bucket name (must be globally unique)"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for SSE-KMS encryption"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable S3 object versioning"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow bucket destruction even if not empty (test only)"
  type        = bool
  default     = false
}

variable "enable_lifecycle_rules" {
  description = "Enable S3 lifecycle rules for tiering and archival"
  type        = bool
  default     = true
}

variable "intelligent_tiering_days" {
  description = "Days before transitioning to Intelligent-Tiering"
  type        = number
  default     = 90
}

variable "glacier_transition_days" {
  description = "Days before transitioning to Glacier Instant Retrieval"
  type        = number
  default     = 1825
}

variable "enable_replication" {
  description = "Enable cross-region replication"
  type        = bool
  default     = false
}

variable "replication_role_arn" {
  description = "IAM role ARN for S3 replication (required when enable_replication=true)"
  type        = string
  default     = ""
}

variable "replication_destination_bucket_arn" {
  description = "ARN of the destination replication bucket"
  type        = string
  default     = ""
}

variable "replication_destination_kms_key_arn" {
  description = "KMS key ARN in the destination region for replica encryption"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
