variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "sns_topic_name" {
  description = "SNS topic name for ops alert notifications"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
