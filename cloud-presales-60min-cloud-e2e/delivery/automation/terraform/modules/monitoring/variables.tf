variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 30
}

variable "dashboard_platform_health" {
  description = "CloudWatch dashboard name for platform health"
  type        = string
}

variable "dashboard_throughput" {
  description = "CloudWatch dashboard name for solution throughput"
  type        = string
}

variable "dashboard_cost_telemetry" {
  description = "CloudWatch dashboard name for Bedrock cost telemetry"
  type        = string
}

variable "dashboard_quota_utilisation" {
  description = "CloudWatch dashboard name for quota utilisation"
  type        = string
}

variable "sns_topic_name" {
  description = "SNS topic name for CloudWatch alarm notifications"
  type        = string
}

variable "lambda_error_rate_threshold_pct" {
  description = "Lambda error rate percentage threshold for P2 alarms"
  type        = number
  default     = 5
}

variable "bedrock_cost_anomaly_threshold_usd" {
  description = "Per-solution Bedrock token spend threshold for anomaly alarm"
  type        = number
  default     = 10.0
}

variable "canary_endpoint_path" {
  description = "Synthetic Canary target endpoint path"
  type        = string
  default     = "/v1/quota"
}

variable "canary_interval_minutes" {
  description = "Synthetic Canary execution interval in minutes"
  type        = number
  default     = 5
}

variable "global_alert_threshold_pct" {
  description = "Global quota alert threshold percentage"
  type        = number
  default     = 90
}

variable "user_alert_threshold_count" {
  description = "Per-user quota alert count threshold"
  type        = number
  default     = 8
}

variable "global_monthly_solution_limit" {
  description = "Global monthly solution limit (for alarm threshold calculation)"
  type        = number
  default     = 1000
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
