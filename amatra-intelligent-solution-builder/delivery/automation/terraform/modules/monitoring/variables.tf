variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment (prod/test/dr)"
  type        = string
}

variable "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 90
}

variable "metrics_namespace" {
  description = "CloudWatch custom metrics namespace"
  type        = string
  default     = "AmatraPlatform"
}

variable "kms_key_arn" {
  description = "KMS key ARN for SNS and CloudWatch Logs encryption"
  type        = string
}

variable "lambda_function_names" {
  description = "Map of Lambda function names for alarm dimensions"
  type        = map(string)
  default     = {}
}

variable "stepfunctions_state_machine_arn" {
  description = "Step Functions state machine ARN"
  type        = string
  default     = ""
}

variable "table_user_profiles_name" {
  description = "DynamoDB user profiles table name"
  type        = string
}

variable "table_quota_global_name" {
  description = "DynamoDB global quota table name"
  type        = string
}

variable "lambda_error_rate_alarm_threshold" {
  description = "Lambda error rate threshold for alarm"
  type        = number
  default     = 1
}

variable "stepfunctions_failure_rate_alarm_threshold" {
  description = "Step Functions failure rate threshold for alarm"
  type        = number
  default     = 2
}

variable "bedrock_daily_spend_alarm_pct" {
  description = "Daily Bedrock spend as percentage of budget to trigger alarm"
  type        = number
  default     = 110
}

variable "token_usage_metric_name" {
  description = "CloudWatch custom metric name for token usage"
  type        = string
  default     = "TokenUsage"
}

variable "monthly_token_budget_millions" {
  description = "Monthly Bedrock token budget in millions"
  type        = number
  default     = 25
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
