#------------------------------------------------------------------------------
# AWS DynamoDB Table - Variables
#------------------------------------------------------------------------------

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode: PAY_PER_REQUEST or PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "Partition key attribute name"
  type        = string
}

variable "range_key" {
  description = "Sort key attribute name (empty string = no sort key)"
  type        = string
  default     = ""
}

variable "attributes" {
  description = "List of attribute definitions (name + type S|N|B)"
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
    projection_type = optional(string, "ALL")
  }))
  default = []
}

variable "ttl_attribute" {
  description = "TTL attribute name (empty string disables TTL)"
  type        = string
  default     = ""
}

variable "pitr_enabled" {
  description = "Enable Point-in-Time Recovery"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
