variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "table_user_profiles" {
  description = "DynamoDB table name for user profiles"
  type        = string
}

variable "table_solution_state" {
  description = "DynamoDB table name for solution state"
  type        = string
}

variable "table_quota_global" {
  description = "DynamoDB table name for global quota"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "pitr_enabled" {
  description = "Enable Point-in-Time Recovery"
  type        = bool
  default     = true
}

variable "solution_state_ttl_days" {
  description = "TTL in days for solution state records"
  type        = number
  default     = 90
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
