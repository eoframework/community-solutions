variable "topic_name" {
  description = "SNS topic name"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for SNS encryption (empty string to skip)"
  type        = string
  default     = ""
}

variable "email_subscriptions" {
  description = "List of email addresses to subscribe to the topic"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
