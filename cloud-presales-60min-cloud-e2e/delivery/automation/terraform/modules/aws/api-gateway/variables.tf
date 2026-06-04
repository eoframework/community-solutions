variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "prod"
}

variable "throttle_burst_limit" {
  description = "API Gateway stage burst throttle limit"
  type        = number
  default     = 10000
}

variable "throttle_rate_limit" {
  description = "API Gateway stage steady-state RPS throttle limit"
  type        = number
  default     = 5000
}

variable "custom_domain" {
  description = "Custom domain name for API Gateway"
  type        = string
  default     = ""
}

variable "tls_minimum_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "TLS_1_2"
}

variable "xray_tracing_enabled" {
  description = "Enable X-Ray tracing on API Gateway stage"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID for JWT authoriser"
  type        = string
}

variable "cognito_user_pool_endpoint" {
  description = "Cognito User Pool endpoint for JWT issuer URL"
  type        = string
}

variable "solution_create_function_arn" {
  description = "Solution Create Lambda function ARN"
  type        = string
}

variable "status_function_arn" {
  description = "Status Lambda function ARN"
  type        = string
}

variable "artifact_fetch_function_arn" {
  description = "Artifact Fetch Lambda function ARN"
  type        = string
}

variable "admin_usage_function_arn" {
  description = "Admin Usage Lambda function ARN"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
