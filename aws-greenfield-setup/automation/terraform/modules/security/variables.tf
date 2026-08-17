variable "name_prefix" {
  description = "Prefix for resource names (e.g., ins-prod)"
  type        = string
}

variable "region" {
  description = "AWS region where security services are deployed"
  type        = string
}

variable "kms_key_rotation_enabled" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = true
}

variable "enable_secondary_kms" {
  description = "Create a secondary region KMS key"
  type        = bool
  default     = false
}

variable "guardduty_enabled" {
  description = "Enable GuardDuty"
  type        = bool
  default     = true
}

variable "guardduty_delegated_admin_account_id" {
  description = "AWS account ID for the GuardDuty delegated administrator"
  type        = string
  default     = null
}

variable "securityhub_fsbp_enabled" {
  description = "Enable Security Hub FSBP standard"
  type        = bool
  default     = true
}

variable "securityhub_nist_enabled" {
  description = "Enable Security Hub NIST 800-53 standard"
  type        = bool
  default     = false
}

variable "securityhub_delegated_admin_account_id" {
  description = "AWS account ID for the Security Hub delegated administrator"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
