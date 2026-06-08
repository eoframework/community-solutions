variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "eventbridge_catalog_bus_name" {
  description = "EventBridge custom event bus name for catalog upload events"
  type        = string
}

variable "sqs_feedback_queue_retention_seconds" {
  description = "SQS message retention period in seconds for the feedback queue"
  type        = number
  default     = 345600
}

variable "sqs_max_receive_count" {
  description = "Number of receive attempts before routing to DLQ"
  type        = number
  default     = 3
}

variable "user_data_kms_key_arn" {
  description = "KMS key ARN for SQS queue encryption"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
