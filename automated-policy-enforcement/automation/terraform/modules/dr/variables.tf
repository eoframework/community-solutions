variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "dr_region" {
  description = "AWS DR region (ap-southeast-4)"
  type        = string
}

variable "rto_hours" {
  description = "Recovery Time Objective in hours"
  type        = number
  default     = 4
}

variable "rpo_hours" {
  description = "Recovery Point Objective in hours"
  type        = number
  default     = 1
}

variable "failover_activation_minutes" {
  description = "Minutes of disruption before DR activation is triggered"
  type        = number
  default     = 30
}

variable "log_archive_bucket_name" {
  description = "Name of the primary log archive S3 bucket"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS CMK for DR vault encryption"
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

variable "sns_topic_arn" {
  description = "SNS topic ARN for DR alarm notifications"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
