variable "name_prefix" {
  description = "Naming prefix for monitoring resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "operations_dashboard_name" {
  description = "CloudWatch Operations Dashboard name"
  type        = string
}

variable "sla_dashboard_name" {
  description = "CloudWatch SLA Dashboard name"
  type        = string
}

variable "quality_dashboard_name" {
  description = "CloudWatch Quality & Usage Dashboard name"
  type        = string
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

variable "job_failure_rate_threshold_pct" {
  description = "Step Functions failure rate alarm threshold percentage"
  type        = number
  default     = 5
}

variable "api_5xx_threshold_pct" {
  description = "API Gateway 5xx error threshold"
  type        = number
  default     = 1
}

variable "bedrock_budget_warning_pct" {
  description = "Bedrock token budget warning threshold percentage"
  type        = number
  default     = 80
}

variable "dlq_depth_threshold" {
  description = "SQS DLQ depth alarm threshold"
  type        = number
  default     = 1
}

variable "cognito_auth_failure_pct" {
  description = "Cognito authentication failure rate threshold"
  type        = number
  default     = 10
}

variable "health_check_interval_seconds" {
  description = "Synthetics canary polling interval in seconds"
  type        = number
  default     = 60
}

variable "api_version" {
  description = "API version string for health check URL"
  type        = string
  default     = "v1"
}

variable "rest_api_id" {
  description = "API Gateway REST API ID"
  type        = string
}

variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
}

variable "dlq_name" {
  description = "SQS DLQ name for alarm dimensions"
  type        = string
}

variable "state_machine_arn" {
  description = "Step Functions state machine ARN for alarm dimensions"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID for alarm dimensions"
  type        = string
}

variable "bedrock_max_input_tokens" {
  description = "Bedrock monthly input token budget"
  type        = number
  default     = 10000000
}

variable "bedrock_max_output_tokens" {
  description = "Bedrock monthly output token budget"
  type        = number
  default     = 5000000
}
