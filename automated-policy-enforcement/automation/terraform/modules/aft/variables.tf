variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "itsm_approval_required" {
  description = "Require ITSM change-approval before AFT pipeline executes"
  type        = bool
  default     = true
}

variable "max_concurrent_requests" {
  description = "Maximum concurrent account vending requests"
  type        = number
  default     = 5
}

variable "account_provisioning_timeout_minutes" {
  description = "Maximum time in minutes for end-to-end AFT account vending"
  type        = number
  default     = 60
}

variable "aft_workflow_table_name" {
  description = "Name of the DynamoDB table storing AFT workflow state"
  type        = string
}

variable "lambda_memory_mb" {
  description = "Memory allocation in MB for AFT Lambda functions"
  type        = number
  default     = 3008
}

variable "log_level" {
  description = "Logging verbosity level for Lambda functions"
  type        = string
  default     = "info"
}

variable "kms_key_arn" {
  description = "ARN of the KMS CMK for encrypting pipeline artifacts and logs"
  type        = string
}

variable "tf_state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state and pipeline artifacts"
  type        = string
}

variable "tf_lock_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
