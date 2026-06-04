variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "user_pool_name" {
  description = "Cognito User Pool name"
  type        = string
}

variable "access_token_validity" {
  description = "Access token validity in seconds"
  type        = number
  default     = 3600
}

variable "refresh_token_validity_days" {
  description = "Refresh token validity in days"
  type        = number
  default     = 30
}

variable "mfa_configuration" {
  description = "MFA configuration: OFF, OPTIONAL, or ON"
  type        = string
  default     = "OFF"

  validation {
    condition     = contains(["OFF", "OPTIONAL", "ON"], var.mfa_configuration)
    error_message = "mfa_configuration must be OFF, OPTIONAL, or ON."
  }
}

variable "group_consultants" {
  description = "Cognito group name for consultant users"
  type        = string
  default     = "consultants"
}

variable "group_admins" {
  description = "Cognito group name for admin users"
  type        = string
  default     = "admin"
}

variable "post_confirmation_lambda_arn" {
  description = "ARN of the post-confirmation Lambda trigger"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
