variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "dashboard_platform_ops" {
  description = "CloudWatch dashboard name for AFT pipeline health and Config compliance"
  type        = string
}

variable "dashboard_identity" {
  description = "CloudWatch dashboard name for IAM Identity Center login events"
  type        = string
}

variable "dashboard_dr" {
  description = "CloudWatch dashboard name for S3 CRR lag and DR replication health"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 90
}

variable "dlq_name" {
  description = "Name of the SIEM forwarding DLQ (for dashboard widget)"
  type        = string
}

variable "dlq_alarm_threshold" {
  description = "DLQ message count alarm threshold"
  type        = number
  default     = 0
}

variable "config_rule_count" {
  description = "Expected number of AWS Config rules deployed"
  type        = number
  default     = 80
}

variable "finding_volume_monthly" {
  description = "Expected Security Hub finding volume per month"
  type        = number
  default     = 1000
}

variable "kms_key_arn" {
  description = "ARN of the KMS CMK for SNS topic and CloudWatch Logs encryption"
  type        = string
}

variable "siem_dlq_url" {
  description = "URL of the SIEM forwarding DLQ (for reference)"
  type        = string
  default     = ""
}

variable "aft_pipeline_name" {
  description = "Name of the AFT CodePipeline (for dashboard widgets)"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
