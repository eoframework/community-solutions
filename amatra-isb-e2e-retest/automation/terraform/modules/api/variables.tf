variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID for JWT authoriser"
  type        = string
}

variable "cognito_app_client_id" {
  description = "Cognito App Client ID for JWT audience"
  type        = string
}

variable "cors_allow_origins" {
  description = "Allowed CORS origins"
  type        = list(string)
  default     = ["*"]
}

variable "throttle_burst_limit" {
  description = "API Gateway burst throttle limit (RPS)"
  type        = number
  default     = 1000
}

variable "throttle_rate_limit" {
  description = "API Gateway steady-state throttle limit (RPS)"
  type        = number
  default     = 500
}

variable "github_dlq_name" {
  description = "SQS FIFO DLQ name for failed GitHub push messages"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
