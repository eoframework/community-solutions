#------------------------------------------------------------------------------
# Database Module (Tier 2) - Variables
#------------------------------------------------------------------------------

variable "catalog_table_name" {
  description = "DynamoDB catalog mood-tag table name"
  type        = string
}

variable "catalog_gsi_name" {
  description = "Catalog table GSI name for mood-label queries"
  type        = string
  default     = "mood_label-index"
}

variable "catalog_pitr_enabled" {
  description = "Enable PITR on catalog moods table"
  type        = bool
  default     = true
}

variable "user_history_table_name" {
  description = "DynamoDB user listening history table name"
  type        = string
}

variable "user_history_ttl_attribute" {
  description = "TTL attribute name for user history records"
  type        = string
  default     = "ttl"
}

variable "user_history_pitr_enabled" {
  description = "Enable PITR on user history table"
  type        = bool
  default     = true
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
