variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the platform KMS CMK"
  type        = string
}

variable "kms_key_id" {
  description = "ID of the platform KMS CMK"
  type        = string
}

variable "deny_console_access_policy_name" {
  description = "Name of the SCP that blocks IAM user creation and console sign-in in production OU"
  type        = string
}

variable "region_lock_allowed_regions" {
  description = "Allowed AWS regions enforced by the region-lock SCP"
  type        = list(string)
}

variable "encryption_enforce_policy_name" {
  description = "Name of the SCP mandating encryption at rest for S3 and EBS"
  type        = string
}

variable "console_access_blocked_in_prod" {
  description = "Whether production console access deny SCP is active"
  type        = bool
}

variable "session_timeout_minutes" {
  description = "IAM Identity Center SSO session duration in minutes"
  type        = number
}

variable "breakglass_session_minutes" {
  description = "Maximum session duration for the BreakGlass emergency access role in minutes"
  type        = number
}

variable "permission_set_developer" {
  description = "IAM Identity Center permission set name for developer access"
  type        = string
}

variable "permission_set_operator" {
  description = "IAM Identity Center permission set name for platform operator access"
  type        = string
}

variable "permission_set_security_viewer" {
  description = "IAM Identity Center permission set name for read-only security access"
  type        = string
}

variable "credentials_rotation_days" {
  description = "Maximum age in days for integration API credentials before mandatory rotation"
  type        = number
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
