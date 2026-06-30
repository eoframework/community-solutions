variable "name_prefix" {
  description = "Prefix for IAM resource names"
  type        = string
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "bucket_suffix" {
  description = "Short suffix used in IAM resource names to differentiate multiple buckets"
  type        = string
  default     = "bucket"
}

variable "kms_key_arn" {
  description = "KMS key ARN for server-side encryption"
  type        = string
}

variable "data_classification" {
  description = "Data classification tag value (e.g. phi-restricted, sensitive, internal)"
  type        = string
  default     = "internal"
}

variable "enable_object_lock" {
  description = "Enable S3 Object Lock for WORM compliance"
  type        = bool
  default     = false
}

variable "object_lock_retention_years" {
  description = "Object Lock compliance retention period in years"
  type        = number
  default     = 7
}

variable "lifecycle_rules" {
  description = "List of lifecycle rule configurations"
  type        = list(any)
  default     = []
}

variable "enable_replication" {
  description = "Enable cross-region replication"
  type        = bool
  default     = false
}

variable "replication_destination_bucket_arn" {
  description = "ARN of the destination bucket for replication"
  type        = string
  default     = null
}

variable "replication_destination_kms_key_arn" {
  description = "KMS key ARN in destination region for replicated objects"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
