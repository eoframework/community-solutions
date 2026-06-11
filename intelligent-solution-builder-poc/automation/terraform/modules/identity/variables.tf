variable "user_pool_name" {
  description = "Cognito User Pool name"
  type        = string
}

variable "user_pool_domain" {
  description = "Cognito hosted UI domain prefix"
  type        = string
}

variable "access_token_validity_hours" {
  description = "Access token validity in hours"
  type        = number
  default     = 1
}

variable "callback_urls" {
  description = "OAuth 2.0 callback URLs"
  type        = list(string)
  default     = ["https://localhost"]
}

variable "logout_urls" {
  description = "OAuth 2.0 logout URLs"
  type        = list(string)
  default     = ["https://localhost"]
}

variable "user_groups" {
  description = "Cognito user group names"
  type        = list(string)
  default     = ["presales-consultants", "delivery-consultants", "admins"]
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
