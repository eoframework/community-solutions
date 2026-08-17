variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for SNS topic encryption"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudWatch log group encryption"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 90
}

variable "dashboard_name_ops" {
  description = "Name of the Landing Zone Operations CloudWatch dashboard"
  type        = string
  default     = "ins-landing-zone-ops"
}

variable "dashboard_name_security" {
  description = "Name of the Security Posture CloudWatch dashboard"
  type        = string
  default     = "ins-security-posture"
}

variable "dashboard_name_finops" {
  description = "Name of the FinOps CloudWatch dashboard"
  type        = string
  default     = "ins-finops"
}

variable "guardduty_alert_threshold" {
  description = "GuardDuty finding severity threshold for HIGH alerts"
  type        = number
  default     = 7.0
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
