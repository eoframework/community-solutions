variable "api_name" {
  description = "API Gateway REST API name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN for the JWT authoriser"
  type        = string
}

variable "kms_audit_key_arn" {
  description = "KMS audit key ARN for log group encryption"
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
