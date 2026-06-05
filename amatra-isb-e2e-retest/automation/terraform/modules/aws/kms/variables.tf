variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "description" {
  description = "KMS key description"
  type        = string
  default     = "Customer managed key"
}

variable "key_alias_suffix" {
  description = "Suffix for the key alias (after name_prefix)"
  type        = string
  default     = "key"
}

variable "deletion_window_in_days" {
  description = "Waiting period before key deletion (7-30 days)"
  type        = number
  default     = 30
}

variable "rotation_period_in_days" {
  description = "Key rotation period in days"
  type        = number
  default     = 90
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
