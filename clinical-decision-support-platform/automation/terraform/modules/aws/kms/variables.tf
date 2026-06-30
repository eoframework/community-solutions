variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "key_alias_suffix" {
  description = "Suffix added after name_prefix for the KMS alias (e.g. aurora, healthlake)"
  type        = string
}

variable "description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS Customer Managed Key"
}

variable "deletion_window_in_days" {
  description = "Waiting period before key deletion (7-30 days)"
  type        = number
  default     = 30
}

variable "multi_region" {
  description = "Enable multi-region key for cross-region replication support"
  type        = bool
  default     = false
}

variable "key_policy" {
  description = "JSON key policy document; null = AWS default policy"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
