variable "name_prefix" {
  description = "Naming prefix for security resources"
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

variable "kms_s3_key_arn" {
  description = "KMS key ARN for S3 encryption"
  type        = string
}

variable "kms_secrets_key_arn" {
  description = "KMS key ARN for Secrets Manager encryption"
  type        = string
}

variable "cognito" {
  description = "Cognito configuration"
  type = object({
    admin_group_name    = string
    presales_group_name = string
    delivery_group_name = string
    mfa_enforcement     = string
    token_expiry_minutes = number
  })
}

variable "waf_rate_limit" {
  description = "WAF rate limit: max requests per IP per 5-minute window"
  type        = number
  default     = 2000
}

variable "enable_waf" {
  description = "Create and attach WAF WebACL to API Gateway"
  type        = bool
  default     = true
}

variable "enable_guardduty" {
  description = "Enable AWS GuardDuty threat detection"
  type        = bool
  default     = true
}

variable "enable_securityhub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = true
}

variable "s3_block_public_access" {
  description = "Enforce S3 Block Public Access"
  type        = bool
  default     = true
}

variable "session_timeout_minutes" {
  description = "Session idle timeout in minutes"
  type        = number
  default     = 30
}
