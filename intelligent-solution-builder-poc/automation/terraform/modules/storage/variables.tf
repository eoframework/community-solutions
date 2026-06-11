variable "artifacts_bucket_name" {
  description = "S3 bucket name for generated artifacts"
  type        = string
}

variable "terraform_state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "solution_state_table_name" {
  description = "DynamoDB table name for solution state records"
  type        = string
}

variable "usage_tracking_table_name" {
  description = "DynamoDB table name for per-user usage counters"
  type        = string
}

variable "audit_table_name" {
  description = "DynamoDB table name for audit records"
  type        = string
}

variable "terraform_lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
}

variable "kms_artifacts_key_arn" {
  description = "KMS key ARN for S3 artifact bucket encryption"
  type        = string
}

variable "kms_database_key_arn" {
  description = "KMS key ARN for DynamoDB table encryption"
  type        = string
}

variable "s3_versioning_enabled" {
  description = "Enable S3 versioning on the artifacts bucket"
  type        = bool
  default     = true
}

variable "s3_intelligent_tiering_days" {
  description = "Days before S3 Intelligent-Tiering transition"
  type        = number
  default     = 90
}

variable "s3_glacier_transition_days" {
  description = "Days before S3 Glacier transition"
  type        = number
  default     = 1825
}

variable "pitr_enabled" {
  description = "Enable DynamoDB PITR"
  type        = bool
  default     = true
}

variable "deletion_protection_enabled" {
  description = "Enable DynamoDB deletion protection"
  type        = bool
  default     = true
}

variable "enable_s3_replication" {
  description = "Enable cross-region S3 replication"
  type        = bool
  default     = false
}

variable "s3_replication_role_arn" {
  description = "IAM role ARN for S3 cross-region replication"
  type        = string
  default     = ""
}

variable "dr_replication_bucket_arn" {
  description = "ARN of the DR S3 replication destination bucket"
  type        = string
  default     = ""
}

variable "dr_replication_kms_key_arn" {
  description = "KMS key ARN in the DR region for replica encryption"
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "Allow S3 bucket destruction even if not empty (test only)"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
