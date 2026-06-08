variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "content_catalog_table" {
  description = "DynamoDB table name for enriched content catalog"
  type        = string
}

variable "user_profile_table" {
  description = "DynamoDB table name for user preference vectors"
  type        = string
}

variable "interaction_events_table" {
  description = "DynamoDB table name for interaction events"
  type        = string
}

variable "mood_taxonomy_table" {
  description = "DynamoDB table name for mood taxonomy reference data"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode (PAY_PER_REQUEST or PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "pitr_enabled" {
  description = "Enable DynamoDB Point-in-Time Recovery"
  type        = bool
  default     = true
}

variable "interaction_retention_days" {
  description = "Retention period in days for interaction event records"
  type        = number
  default     = 730
}

variable "user_data_kms_key_arn" {
  description = "KMS key ARN for user data tables"
  type        = string
}

variable "catalog_kms_key_arn" {
  description = "KMS key ARN for catalog tables"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
