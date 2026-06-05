variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "description" {
  description = "KMS key description"
  type        = string
  default     = "Customer-managed KMS key"
}

variable "enable_rotation" {
  description = "Enable automatic annual key rotation"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
