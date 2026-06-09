variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the platform KMS CMK for S3 SSE-KMS"
  type        = string
}

variable "log_archive_object_lock_mode" {
  description = "S3 Object Lock mode for the log archive bucket (COMPLIANCE or GOVERNANCE)"
  type        = string
  default     = "COMPLIANCE"
  validation {
    condition     = contains(["COMPLIANCE", "GOVERNANCE"], var.log_archive_object_lock_mode)
    error_message = "log_archive_object_lock_mode must be COMPLIANCE or GOVERNANCE."
  }
}

variable "log_retention_years" {
  description = "CloudTrail log retention in years (enforced via S3 Object Lock)"
  type        = number
  default     = 1
}

variable "tf_state_versioning_enabled" {
  description = "Enable S3 versioning on the Terraform state bucket"
  type        = bool
  default     = true
}

variable "dr_region" {
  description = "AWS DR region for S3 CRR destination"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
