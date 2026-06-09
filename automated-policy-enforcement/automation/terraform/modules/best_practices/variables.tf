variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS CMK for backup vault encryption"
  type        = string
}

variable "backup_plan_name" {
  description = "AWS Backup plan name"
  type        = string
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 30
}

variable "backup_dr_replication_enabled" {
  description = "Enable AWS Backup cross-region replication to DR region"
  type        = bool
  default     = false
}

variable "dr_region" {
  description = "DR region for cross-region backup copy"
  type        = string
  default     = ""
}

variable "guardduty_enabled" {
  description = "Enable GuardDuty organisational detector"
  type        = bool
  default     = true
}

variable "securityhub_fsbp_enabled" {
  description = "Enable AWS Foundational Security Best Practices standard in Security Hub"
  type        = bool
  default     = true
}

variable "securityhub_cis_enabled" {
  description = "Enable CIS AWS Foundations Benchmark standard in Security Hub"
  type        = bool
  default     = true
}

variable "config_rule_count" {
  description = "Expected number of AWS Config rules (for documentation)"
  type        = number
  default     = 80
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 90
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for backup job notifications"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
