variable "name_prefix" {
  description = "Naming prefix for database resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "kms_dynamodb_key_arn" {
  description = "KMS CMK ARN for DynamoDB encryption"
  type        = string
}

variable "solution_state_table_name" {
  description = "DynamoDB table name for solution job state"
  type        = string
}

variable "usage_tracking_table_name" {
  description = "DynamoDB table name for per-user/global usage counters"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "pitr_enabled" {
  description = "Enable Point-in-Time Recovery (required in prod for RPO ≤15 min)"
  type        = bool
  default     = true
}

variable "ttl_solution_state_days" {
  description = "TTL for COMPLETE SolutionState records in days"
  type        = number
  default     = 365
}

variable "ttl_usage_tracking_days" {
  description = "TTL for UsageTracking records in days"
  type        = number
  default     = 365
}
