variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "account_id" {
  description = "AWS account ID for globally unique bucket naming"
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

variable "glacier_transition_days" {
  description = "Days before non-current versions transition to Glacier (0 = disabled)"
  type        = number
  default     = 30
}

variable "artifact_retention_days" {
  description = "Days before artifacts expire"
  type        = number
  default     = 365
}

variable "enforce_ssl" {
  description = "Enforce HTTPS-only access via bucket policy"
  type        = bool
  default     = true
}

variable "cloudtrail_enabled" {
  description = "Create a separate CloudTrail audit bucket"
  type        = bool
  default     = true
}

variable "cloudtrail_retention_days" {
  description = "CloudTrail log retention in days"
  type        = number
  default     = 365
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
