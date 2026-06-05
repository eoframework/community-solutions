variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "description" {
  description = "API Gateway description"
  type        = string
  default     = "EO Framework HTTP API"
}

variable "region" {
  description = "AWS region"
  type        = string
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
  description = "API Gateway burst throttle limit"
  type        = number
  default     = 1000
}

variable "throttle_rate_limit" {
  description = "API Gateway steady-state rate limit"
  type        = number
  default     = 500
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
