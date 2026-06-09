variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS CMK for Lambda env encryption"
  type        = string
}

variable "lambda_memory_mb" {
  description = "Memory allocation in MB for the ITSM integration Lambda"
  type        = number
  default     = 512
}

variable "reserved_concurrency" {
  description = "Reserved concurrency for the ITSM integration Lambda"
  type        = number
  default     = 5
}

variable "approval_poll_interval_seconds" {
  description = "Interval in seconds at which the Lambda polls ITSM for approval status"
  type        = number
  default     = 120
}

variable "change_freeze_scp_condition" {
  description = "Enable SCP condition that denies AFT execution without approved ITSM record during change freeze"
  type        = bool
  default     = true
}

variable "log_level" {
  description = "Logging verbosity level for the Lambda function"
  type        = string
  default     = "info"
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days for ITSM Lambda log group"
  type        = number
  default     = 90
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
