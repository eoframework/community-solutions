variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "topic_name" {
  description = "SNS topic name"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
