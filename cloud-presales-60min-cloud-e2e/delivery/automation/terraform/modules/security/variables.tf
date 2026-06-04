variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "waf_rate_limit_requests_per_ip_per_minute" {
  description = "WAF IP-based rate limit in requests per IP per minute"
  type        = number
  default     = 100
}

variable "waf_managed_rules_enabled" {
  description = "Enable WAF with AWS Managed Common Rule Set"
  type        = bool
  default     = true
}

variable "cloudtrail_enabled" {
  description = "Enable CloudTrail audit logging"
  type        = bool
  default     = true
}

variable "cloudtrail_s3_bucket_name" {
  description = "S3 bucket name for CloudTrail log delivery"
  type        = string
}

variable "cloudtrail_log_retention_days" {
  description = "CloudWatch log retention for CloudTrail forwarded logs"
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
