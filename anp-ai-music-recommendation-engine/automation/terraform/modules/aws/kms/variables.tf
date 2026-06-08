variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "key_alias" {
  description = "KMS key alias (e.g. alias/anp-prod-catalog)"
  type        = string
}

variable "description" {
  description = "Description of the KMS key purpose"
  type        = string
  default     = "ANP Streaming AI Recommendation Engine CMK"
}

variable "enable_key_rotation" {
  description = "Enable automatic annual key rotation"
  type        = bool
  default     = true
}

variable "deletion_window_in_days" {
  description = "Number of days before the key is deleted after scheduling deletion"
  type        = number
  default     = 30
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
