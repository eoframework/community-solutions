variable "name_prefix" {
  description = "Resource name prefix (used for tagging)"
  type        = string
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable S3 object versioning"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for server-side encryption"
  type        = string
}

variable "lifecycle_ia_days" {
  description = "Days before transitioning to S3 Infrequent Access (0 = disabled)"
  type        = number
  default     = 90
}

variable "lifecycle_glacier_days" {
  description = "Days before transitioning to S3 Glacier (0 = disabled)"
  type        = number
  default     = 365
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
