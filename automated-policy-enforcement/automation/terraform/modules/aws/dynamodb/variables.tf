variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS CMK for DynamoDB encryption"
  type        = string
}

variable "aft_table_name" {
  description = "Name of the AFT workflow state DynamoDB table"
  type        = string
}

variable "aft_billing_mode" {
  description = "DynamoDB billing mode for AFT workflow table"
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.aft_billing_mode)
    error_message = "aft_billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "aft_backup_enabled" {
  description = "Enable point-in-time recovery on the AFT workflow table"
  type        = bool
  default     = true
}

variable "tf_lock_table_name" {
  description = "Name of the Terraform state locking DynamoDB table"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
