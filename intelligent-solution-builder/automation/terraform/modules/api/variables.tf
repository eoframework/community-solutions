variable "name_prefix" {
  description = "Naming prefix for API resources"
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

variable "api_name" {
  description = "API Gateway REST API name"
  type        = string
}

variable "api_version" {
  description = "API version path segment (e.g. v1)"
  type        = string
  default     = "v1"
}

variable "stage_name" {
  description = "API Gateway stage name"
  type        = string
}

variable "throttle_burst_rps" {
  description = "API Gateway burst throttle limit in RPS"
  type        = number
  default     = 500
}

variable "throttle_steady_rps" {
  description = "API Gateway steady-state throttle limit in RPS"
  type        = number
  default     = 200
}

variable "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN for JWT authorizer"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 30
}
