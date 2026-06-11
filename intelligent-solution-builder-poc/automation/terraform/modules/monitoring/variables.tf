variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "dashboard_name" {
  description = "CloudWatch dashboard name"
  type        = string
}

variable "trail_name" {
  description = "CloudTrail trail name"
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = "S3 bucket for CloudTrail logs"
  type        = string
}

variable "kms_audit_key_arn" {
  description = "KMS audit key ARN"
  type        = string
}

variable "cloudtrail_include_data_events" {
  description = "Enable CloudTrail S3 and DynamoDB data events"
  type        = bool
  default     = true
}

variable "api_name" {
  description = "API Gateway name for alarm dimensions"
  type        = string
  default     = ""
}

variable "step_functions_arn" {
  description = "Step Functions ARN for alarms"
  type        = string
  default     = ""
}

variable "generation_queue_name" {
  description = "SQS generation queue name"
  type        = string
  default     = ""
}

variable "dlq_name" {
  description = "SQS DLQ name"
  type        = string
  default     = ""
}

variable "api_error_rate_threshold_pct" {
  description = "API 5xx error rate threshold percentage"
  type        = number
  default     = 1
}

variable "dlq_message_threshold" {
  description = "DLQ message count alarm threshold"
  type        = number
  default     = 0
}

variable "sfn_failure_threshold" {
  description = "Step Functions failure count threshold"
  type        = number
  default     = 5
}

variable "api_latency_p95_threshold_ms" {
  description = "API Gateway P95 latency threshold in milliseconds"
  type        = number
  default     = 5000
}

variable "force_destroy" {
  description = "Allow CloudTrail S3 bucket deletion when not empty"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
