variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "key_purpose" {
  description = "Purpose suffix for key alias (e.g., artifacts, database, secrets, audit)"
  type        = string
}

variable "description" {
  description = "KMS key description"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Key deletion window in days"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable automatic annual key rotation"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
