variable "region" {
  description = "AWS region where Security Hub is being enabled"
  type        = string
}

variable "enable_fsbp" {
  description = "Enable AWS Foundational Security Best Practices standard"
  type        = bool
  default     = true
}

variable "enable_nist" {
  description = "Enable NIST 800-53 Rev 5 standard"
  type        = bool
  default     = false
}

variable "delegated_admin_account_id" {
  description = "AWS account ID for the Security Hub delegated administrator. Null skips delegation."
  type        = string
  default     = null
}
