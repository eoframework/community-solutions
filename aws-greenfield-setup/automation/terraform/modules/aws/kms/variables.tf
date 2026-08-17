variable "key_alias" {
  description = "Alias name for the KMS key (without alias/ prefix)"
  type        = string
}

variable "description" {
  description = "Description for the KMS key"
  type        = string
  default     = "Customer-managed KMS key"
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable automatic annual key rotation"
  type        = bool
  default     = true
}

variable "multi_region" {
  description = "Create a multi-Region primary key"
  type        = bool
  default     = false
}

variable "key_policy" {
  description = "IAM policy document for the KMS key (JSON). Null uses default."
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
