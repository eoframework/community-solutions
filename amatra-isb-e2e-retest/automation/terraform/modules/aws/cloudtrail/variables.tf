variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "retention_days" {
  description = "CloudTrail log retention in days"
  type        = number
  default     = 365
}

variable "cloudwatch_retention_days" {
  description = "CloudWatch Logs retention for CloudTrail in days"
  type        = number
  default     = 365
}

variable "s3_data_events_bucket_arn" {
  description = "S3 bucket ARN to enable data events (empty string to disable)"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
