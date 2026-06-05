variable "queue_name" {
  description = "SQS queue name (must end in .fifo for FIFO queues)"
  type        = string
}

variable "fifo_queue" {
  description = "Create a FIFO queue"
  type        = bool
  default     = true
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO queues"
  type        = bool
  default     = false
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout in seconds"
  type        = number
  default     = 300
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds (max 1,209,600 = 14 days)"
  type        = number
  default     = 1209600
}

variable "kms_key_id" {
  description = "KMS key ID for server-side encryption (empty string to use SQS managed key)"
  type        = string
  default     = ""
}

variable "queue_policy_json" {
  description = "SQS queue policy JSON (empty string to skip)"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
