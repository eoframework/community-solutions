variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "enabled" {
  description = "Enable CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_bucket" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudTrail log encryption"
  type        = string
}

variable "retention_days" {
  description = "CloudTrail log retention in days"
  type        = number
  default     = 365
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
