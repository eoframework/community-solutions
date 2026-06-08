variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "raw_catalog_bucket" {
  description = "S3 bucket name for source audio files"
  type        = string
}

variable "transcripts_bucket" {
  description = "S3 bucket name for lyric and transcript text files"
  type        = string
}

variable "features_bucket" {
  description = "S3 bucket name for computed audio feature vectors"
  type        = string
}

variable "models_bucket" {
  description = "S3 bucket name for SageMaker training artifacts"
  type        = string
}

variable "cloudtrail_bucket" {
  description = "S3 bucket name for CloudTrail event logs"
  type        = string
}

variable "lifecycle_ia_days" {
  description = "Days before objects transition to S3-IA storage class (0 = disabled)"
  type        = number
  default     = 90
}

variable "lifecycle_glacier_days" {
  description = "Days before objects transition to Glacier (0 = disabled)"
  type        = number
  default     = 365
}

variable "versioning_enabled" {
  description = "Enable S3 versioning on all buckets"
  type        = bool
  default     = true
}

variable "catalog_kms_key_arn" {
  description = "KMS key ARN for catalog bucket encryption"
  type        = string
}

variable "model_kms_key_arn" {
  description = "KMS key ARN for model artifact bucket encryption"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
