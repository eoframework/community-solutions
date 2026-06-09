#------------------------------------------------------------------------------
# API Module (Tier 2) - Variables
#------------------------------------------------------------------------------

variable "api_name" {
  description = "API Gateway REST API name"
  type        = string
}

variable "stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "v1"
}

variable "rate_limit_rps" {
  description = "Rate limit in requests per second"
  type        = number
  default     = 100
}

variable "burst_limit" {
  description = "Burst limit for concurrent requests"
  type        = number
  default     = 200
}

variable "classifier_function_name" {
  description = "Classifier Lambda function name"
  type        = string
}

variable "classifier_invoke_arn" {
  description = "Classifier Lambda invocation ARN"
  type        = string
}

variable "recommender_function_name" {
  description = "Recommender Lambda function name"
  type        = string
}

variable "recommender_invoke_arn" {
  description = "Recommender Lambda invocation ARN"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN for JWT authorizer"
  type        = string
}

variable "enable_xray" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 90
}

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
