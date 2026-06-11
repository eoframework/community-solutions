variable "queue_name" {
  description = "SQS queue name (must end in .fifo for FIFO queues)"
  type        = string
}

variable "fifo_queue" {
  description = "Create a FIFO queue"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication (FIFO only)"
  type        = bool
  default     = true
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 345600
}

variable "visibility_timeout_seconds" {
  description = "Message visibility timeout in seconds"
  type        = number
  default     = 960
}

variable "receive_wait_time_seconds" {
  description = "Long-polling receive wait time"
  type        = number
  default     = 20
}

variable "kms_key_id" {
  description = "KMS key ID or alias for message encryption"
  type        = string
  default     = "alias/aws/sqs"
}

variable "dlq_arn" {
  description = "Dead-letter queue ARN (empty to disable)"
  type        = string
  default     = ""
}

variable "max_receive_count" {
  description = "Max receive count before routing to DLQ"
  type        = number
  default     = 3
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
