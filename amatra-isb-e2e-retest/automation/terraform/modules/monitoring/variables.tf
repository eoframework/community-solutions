variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "monitoring" {
  description = "Monitoring configuration object"
  type = object({
    cloudwatch_dashboard_name       = string
    cloudtrail_bucket_name          = string
    cloudtrail_retention_days       = number
    alarm_lambda_error_rate_pct     = number
    alarm_bedrock_throttle_count    = number
    api_gateway_p99_latency_ms      = number
    alert_email_subscriptions       = list(string)
  })
}

variable "s3_data_events_enabled" {
  description = "Enable CloudTrail S3 data events on artifact bucket"
  type        = bool
  default     = false
}

variable "artifact_bucket_arn" {
  description = "Artifact S3 bucket ARN (for CloudTrail data events)"
  type        = string
  default     = ""
}

variable "api_gateway_id" {
  description = "API Gateway ID for latency alarms"
  type        = string
  default     = ""
}

variable "solutions_table_name" {
  description = "Solutions DynamoDB table name for dashboard metrics"
  type        = string
  default     = ""
}

variable "quotas_table_name" {
  description = "Quotas DynamoDB table name for dashboard metrics"
  type        = string
  default     = ""
}

variable "github_dlq_name" {
  description = "GitHub push SQS DLQ name for alarm"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
