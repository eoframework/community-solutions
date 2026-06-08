variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "queue_name" {
  description = "SQS queue name"
  type        = string
}

variable "is_fifo" {
  description = "Create a FIFO queue"
  type        = bool
  default     = false
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 345600
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for messages in seconds"
  type        = number
  default     = 60
}

variable "kms_key_arn" {
  description = "KMS key ARN for queue encryption"
  type        = string
}

variable "redrive_policy" {
  description = "JSON-encoded SQS redrive policy (for DLQ configuration)"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
