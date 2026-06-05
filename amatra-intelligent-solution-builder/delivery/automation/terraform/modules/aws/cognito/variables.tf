variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "user_pool_name" {
  description = "Cognito User Pool name"
  type        = string
}

variable "refresh_token_validity" {
  description = "Refresh token validity in days"
  type        = number
  default     = 30
}

variable "access_token_validity" {
  description = "Access token validity in hours"
  type        = number
  default     = 1
}

variable "mfa_configuration" {
  description = "MFA configuration: ON, OFF, or OPTIONAL"
  type        = string
  default     = "OPTIONAL"
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
