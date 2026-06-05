variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "database" {
  description = "Database configuration object"
  type = object({
    users_table_name        = string
    solutions_table_name    = string
    quotas_table_name       = string
    audit_events_table_name = string
    billing_mode            = string
    pitr_enabled            = bool
    audit_events_ttl_days   = number
  })
}

variable "deletion_protection_enabled" {
  description = "Enable DynamoDB deletion protection"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
