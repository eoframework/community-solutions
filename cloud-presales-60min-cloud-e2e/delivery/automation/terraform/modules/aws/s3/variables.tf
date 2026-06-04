variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "S3 bucket name for generated artifacts"
  type        = string
}

variable "guidance_bucket_name" {
  description = "S3 bucket name for EO Framework guidance files"
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail audit logs"
  type        = string
}

variable "artifacts_versioning_enabled" {
  description = "Enable S3 versioning on artifacts bucket"
  type        = bool
  default     = true
}

variable "artifacts_intelligent_tiering_days" {
  description = "Days after which to transition objects to Intelligent-Tiering"
  type        = number
  default     = 90
}

variable "s3_version_retention_days" {
  description = "Days to retain non-current object versions"
  type        = number
  default     = 365
}

variable "artifacts_prefix_raw" {
  description = "S3 key prefix for raw artifacts"
  type        = string
  default     = "raw/"
}

variable "artifacts_prefix_converted" {
  description = "S3 key prefix for converted artifacts"
  type        = string
  default     = "converted/"
}

variable "terraform_prefix" {
  description = "S3 key prefix for Terraform automation bundles"
  type        = string
  default     = "terraform/"
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
