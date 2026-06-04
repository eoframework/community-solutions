variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "pitr_enabled" {
  description = "Enable Point-In-Time Recovery on all tables"
  type        = bool
  default     = true
}

variable "users_table_name" {
  description = "DynamoDB Users table name"
  type        = string
}

variable "solutions_table_name" {
  description = "DynamoDB Solutions table name"
  type        = string
}

variable "global_quota_table_name" {
  description = "DynamoDB GlobalQuota table name"
  type        = string
}

variable "encryption_key_alias" {
  description = "KMS key alias for DynamoDB encryption"
  type        = string
  default     = "aws/dynamodb"
}

variable "user_monthly_solution_limit" {
  description = "Per-user monthly solution generation limit"
  type        = number
  default     = 10
}

variable "global_monthly_solution_limit" {
  description = "Global monthly solution generation limit"
  type        = number
  default     = 1000
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
