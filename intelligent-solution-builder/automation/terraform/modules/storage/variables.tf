variable "name_prefix" {
  description = "Naming prefix for storage resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "kms_s3_key_arn" {
  description = "KMS CMK ARN for S3 SSE-KMS encryption"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "S3 bucket name for generated artifacts"
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail audit logs"
  type        = string
}

variable "templates_bucket_name" {
  description = "S3 bucket name for Bedrock prompt templates"
  type        = string
}

variable "artifacts_lifecycle_standard_days" {
  description = "Days before artifacts transition to S3 Glacier"
  type        = number
  default     = 180
}

variable "versioning_enabled" {
  description = "Enable S3 versioning on the artifacts bucket"
  type        = bool
  default     = true
}

variable "cloudtrail_retention_years" {
  description = "CloudTrail bucket Object Lock retention in years"
  type        = number
  default     = 7
}
