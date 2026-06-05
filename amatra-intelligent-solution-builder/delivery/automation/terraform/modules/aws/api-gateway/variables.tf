variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID for JWT authoriser audience"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  type        = string
}

variable "lambda_invoke_arns" {
  description = "Map of Lambda function invoke ARNs"
  type        = map(string)
}

variable "lambda_function_names" {
  description = "Map of Lambda function names"
  type        = map(string)
}

variable "throttle_rate_limit" {
  description = "API Gateway route-level throttle rate limit (requests/second)"
  type        = number
  default     = 100
}

variable "throttle_burst_limit" {
  description = "API Gateway route-level throttle burst limit"
  type        = number
  default     = 200
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
