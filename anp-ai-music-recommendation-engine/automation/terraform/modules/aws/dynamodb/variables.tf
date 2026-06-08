variable "name_prefix" {
  description = "Resource name prefix (for tagging)"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "DynamoDB table hash (partition) key name"
  type        = string
}

variable "hash_key_type" {
  description = "DynamoDB hash key type (S, N, or B)"
  type        = string
  default     = "S"
}

variable "range_key" {
  description = "DynamoDB table range (sort) key name (empty string = no range key)"
  type        = string
  default     = ""
}

variable "range_key_type" {
  description = "DynamoDB range key type (S, N, or B)"
  type        = string
  default     = "S"
}

variable "ttl_attribute" {
  description = "TTL attribute name (empty string = TTL disabled)"
  type        = string
  default     = ""
}

variable "pitr_enabled" {
  description = "Enable Point-in-Time Recovery"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for server-side encryption"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
