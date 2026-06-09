#------------------------------------------------------------------------------
# Storage Module (Tier 2) - Variables
#------------------------------------------------------------------------------

variable "bucket_name" {
  description = "S3 catalog bucket name"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable S3 object versioning"
  type        = bool
  default     = true
}

variable "catalog_prefix" {
  description = "S3 key prefix for catalog files"
  type        = string
  default     = "catalog/"
}

variable "autotagger_lambda_arn" {
  description = "Auto-Tagger Lambda ARN for S3 event notification (empty = disabled)"
  type        = string
  default     = ""
}

variable "autotagger_function_name" {
  description = "Auto-Tagger Lambda function name (required for permission if notification enabled)"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
