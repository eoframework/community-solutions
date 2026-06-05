variable "user_pool_name" {
  description = "Cognito User Pool name"
  type        = string
}

variable "mfa_enabled" {
  description = "Enable MFA (OPTIONAL mode)"
  type        = bool
  default     = false
}

variable "post_confirmation_lambda_arn" {
  description = "Lambda ARN for Cognito post-confirmation trigger"
  type        = string
  default     = ""
}

variable "callback_urls" {
  description = "Allowed callback URLs for app client"
  type        = list(string)
  default     = ["http://localhost:8080/callback"]
}

variable "logout_urls" {
  description = "Allowed logout URLs for app client"
  type        = list(string)
  default     = ["http://localhost:8080/logout"]
}

variable "access_token_expiry_seconds" {
  description = "Access token expiry in seconds"
  type        = number
  default     = 3600
}

variable "refresh_token_expiry_days" {
  description = "Refresh token expiry in days"
  type        = number
  default     = 30
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
