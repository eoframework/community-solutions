variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
}

variable "database" {
  description = "Database configuration object"
  type = object({
    billing_mode              = string
    pitr_enabled              = bool
    users_table_name          = string
    solutions_table_name      = string
    global_quota_table_name   = string
    encryption_key_alias      = string
  })
}
