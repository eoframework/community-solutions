variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for SNS topic encryption. Null disables encryption."
  type        = string
  default     = null
}

variable "topic_policy" {
  description = "JSON policy document for the SNS topic. Null uses default."
  type        = string
  default     = null
}

variable "email_subscriptions" {
  description = "List of email addresses to subscribe to the SNS topic"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
