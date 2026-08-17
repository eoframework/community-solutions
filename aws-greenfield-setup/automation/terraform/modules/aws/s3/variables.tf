variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "force_destroy" {
  description = "Allow destruction of non-empty bucket"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for SSE-KMS encryption. Null uses SSE-S3."
  type        = string
  default     = null
}

variable "object_lock_enabled" {
  description = "Enable S3 Object Lock (requires versioning)"
  type        = bool
  default     = false
}

variable "object_lock_mode" {
  description = "S3 Object Lock default retention mode: COMPLIANCE or GOVERNANCE"
  type        = string
  default     = "COMPLIANCE"
}

variable "object_lock_days" {
  description = "Number of days for Object Lock default retention"
  type        = number
  default     = 90
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type = list(object({
    id                                 = string
    enabled                            = bool
    prefix                             = optional(string, "")
    transitions                        = optional(list(object({ days = number, storage_class = string })), [])
    expiration_days                    = optional(number)
    noncurrent_version_expiration_days = optional(number)
  }))
  default = []
}

variable "bucket_policy" {
  description = "JSON bucket policy document. Null skips policy creation."
  type        = string
  default     = null
}

variable "replication_role_arn" {
  description = "IAM role ARN for S3 Cross-Region Replication. Null disables CRR."
  type        = string
  default     = null
}

variable "replication_rules" {
  description = "List of S3 replication rules"
  type = list(object({
    id                     = string
    enabled                = bool
    destination_bucket_arn = string
    storage_class          = optional(string, "STANDARD")
  }))
  default = []
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
