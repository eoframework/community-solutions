variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "kms_s3_key_arn" {
  description = "KMS key ARN for S3 SSE-KMS encryption"
  type        = string
  default     = ""
}

variable "storage" {
  description = "Storage configuration object"
  type = object({
    artifact_bucket_name                  = string
    guidance_bucket_name                  = string
    artifact_bucket_versioning_enabled    = bool
    artifact_standard_retention_days      = number
    artifact_glacier_retention_days       = number
  })
}

variable "force_destroy" {
  description = "Allow destroying non-empty S3 buckets (test only)"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
