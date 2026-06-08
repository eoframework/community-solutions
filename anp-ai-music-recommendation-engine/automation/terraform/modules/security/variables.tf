variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment (prod, test, dr)"
  type        = string
}

variable "kms_catalog_cmk_alias" {
  description = "KMS alias for catalog data CMK"
  type        = string
}

variable "kms_user_data_cmk_alias" {
  description = "KMS alias for user data CMK"
  type        = string
}

variable "kms_model_artifacts_cmk_alias" {
  description = "KMS alias for model artifacts CMK"
  type        = string
}

variable "kms_rotation_enabled" {
  description = "Enable automatic annual KMS key rotation"
  type        = bool
  default     = true
}

variable "waf_enabled" {
  description = "Enable AWS WAF v2 Web ACL for API Gateway"
  type        = bool
  default     = true
}

variable "guardduty_enabled" {
  description = "Enable Amazon GuardDuty"
  type        = bool
  default     = true
}

variable "cloudtrail_enabled" {
  description = "Enable CloudTrail logging"
  type        = bool
  default     = true
}

variable "iam_access_analyzer_enabled" {
  description = "Enable IAM Access Analyzer"
  type        = bool
  default     = true
}

variable "cognito_token_expiry_minutes" {
  description = "Cognito JWT access token expiry in minutes"
  type        = number
  default     = 60
}

variable "cognito_mfa_enabled" {
  description = "Enable MFA for Cognito admin users"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
}

variable "vpc_id" {
  description = "VPC ID for security group placement"
  type        = string
}

variable "private_subnet_app_ids" {
  description = "Private application subnet IDs"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
