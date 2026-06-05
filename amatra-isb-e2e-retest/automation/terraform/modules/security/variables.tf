variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "security" {
  description = "Security configuration object"
  type = object({
    cognito_user_pool_name               = string
    cognito_mfa_enabled                  = bool
    cognito_access_token_expiry_seconds  = number
    cognito_refresh_token_expiry_days    = number
    kms_rotation_days                    = number
    access_analyzer_enabled              = bool
    guardduty_enabled                    = bool
    securityhub_enabled                  = bool
  })
}

variable "cognito_post_confirmation_lambda_arn" {
  description = "Lambda ARN for the Cognito post-confirmation trigger"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
