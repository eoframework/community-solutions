#------------------------------------------------------------------------------
# AWS SQS Queue - Variables
#------------------------------------------------------------------------------

variable "queue_name" {
  description = "SQS queue name"
  type        = string
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds (default 4 days)"
  type        = number
  default     = 345600
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout in seconds"
  type        = number
  default     = 30
}

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
