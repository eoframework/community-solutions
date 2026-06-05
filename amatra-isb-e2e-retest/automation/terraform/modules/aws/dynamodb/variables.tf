variable "table_name" {
  description = "DynamoDB table name"
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

variable "hash_key" {
  description = "Table partition key attribute name"
  type        = string
}

variable "range_key" {
  description = "Table sort key attribute name (empty string to omit)"
  type        = string
  default     = ""
}

variable "attributes" {
  description = "List of attribute definitions {name, type}"
  type = list(object({
    name = string
    type = string
  }))
}

variable "global_secondary_indexes" {
  description = "List of GSI definitions"
  type = list(object({
    name            = string
    hash_key        = string
    range_key       = optional(string)
    projection_type = string
  }))
  default = []
}

variable "pitr_enabled" {
  description = "Enable DynamoDB Point-In-Time Recovery"
  type        = bool
  default     = true
}

variable "ttl_attribute" {
  description = "Attribute name for TTL (empty string to disable)"
  type        = string
  default     = ""
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
