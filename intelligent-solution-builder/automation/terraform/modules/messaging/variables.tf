variable "name_prefix" {
  description = "Naming prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for SQS encryption"
  type        = string
  default     = null
}

variable "job_queue_name" {
  description = "SQS job queue name"
  type        = string
}

variable "dlq_name" {
  description = "SQS dead letter queue name (used for naming reference)"
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "SQS visibility timeout in seconds"
  type        = number
  default     = 300
}

variable "message_retention_seconds" {
  description = "SQS message retention in seconds"
  type        = number
  default     = 345600
}

variable "max_receive_count" {
  description = "Max receive count before DLQ"
  type        = number
  default     = 3
}
