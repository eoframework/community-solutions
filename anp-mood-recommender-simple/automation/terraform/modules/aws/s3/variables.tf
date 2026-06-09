#------------------------------------------------------------------------------
# AWS S3 Bucket - Variables
#------------------------------------------------------------------------------

variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable S3 object versioning"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "SSE algorithm: AES256 or aws:kms"
  type        = string
  default     = "AES256"
}

variable "lambda_notification_arn" {
  description = "Lambda ARN to notify on ObjectCreated events (empty = disabled)"
  type        = string
  default     = ""
}

variable "notification_prefix" {
  description = "S3 key prefix filter for event notifications"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
