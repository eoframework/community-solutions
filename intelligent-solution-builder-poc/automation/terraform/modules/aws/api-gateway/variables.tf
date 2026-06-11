variable "api_name" {
  description = "API Gateway REST API name"
  type        = string
}

variable "api_description" {
  description = "API Gateway description"
  type        = string
  default     = "Amatra Intelligent Solution Builder REST API"
}

variable "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN for the JWT authoriser"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudWatch Log Group encryption"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 365
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
