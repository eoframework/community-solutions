variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "cluster_identifier" {
  description = "RDS Aurora cluster identifier"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Data subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to Aurora"
  type        = list(string)
  default     = []
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "master_username" {
  description = "Master username (password managed by Secrets Manager)"
  type        = string
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.r6g.large"
}

variable "instance_count" {
  description = "Number of Aurora instances (1 = writer only; 2 = writer + reader)"
  type        = number
  default     = 2
}

variable "kms_key_arn" {
  description = "KMS key ARN for storage encryption"
  type        = string
}

variable "backup_retention_days" {
  description = "Automated backup retention period in days"
  type        = number
  default     = 35
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
