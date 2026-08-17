variable "aft_state_bucket_name" {
  description = "S3 bucket name for AFT Terraform state storage"
  type        = string
}

variable "aft_lock_table_name" {
  description = "DynamoDB table name for AFT Terraform state locking"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting AFT state bucket and DynamoDB table"
  type        = string
  default     = null
}

variable "aft_terraform_version" {
  description = "Terraform version pinned for all AFT pipeline executions"
  type        = string
  default     = "1.9.0"
}

variable "aft_vending_sla_minutes" {
  description = "Maximum time in minutes for a complete AFT account vending run"
  type        = number
  default     = 30
}

variable "aft_codebuild_compute_type" {
  description = "AWS CodeBuild compute type for AFT pipeline stages"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "aft_max_concurrent_vending" {
  description = "Maximum number of concurrent AFT account vending pipelines"
  type        = number
  default     = 5
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
