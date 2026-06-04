variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "cloudtrail_s3_bucket_name" {
  description = "S3 bucket name for CloudTrail log delivery"
  type        = string
}

variable "cloudtrail_log_retention_days" {
  description = "CloudWatch log group retention for CloudTrail forwarded logs"
  type        = number
  default     = 365
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
