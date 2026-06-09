variable "name_prefix" {
  description = "Resource name prefix (solution-environment)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (prod, test, dr)"
  type        = string
}

variable "rotation_enabled" {
  description = "Enable automatic annual KMS key rotation"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
