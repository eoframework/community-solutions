variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "data_subnet_ids" {
  description = "Private data subnet IDs"
  type        = list(string)
}

variable "app_security_group_ids" {
  description = "Application tier security group IDs allowed to reach data tier"
  type        = list(string)
  default     = []
}

variable "kms_aurora_key_arn" {
  description = "KMS key ARN for Aurora encryption"
  type        = string
}

variable "kms_s3_datalake_key_arn" {
  description = "KMS key ARN for S3 data lake encryption"
  type        = string
}

variable "kms_s3_audit_key_arn" {
  description = "KMS key ARN for S3 audit bucket encryption"
  type        = string
}

variable "kms_elasticache_key_arn" {
  description = "KMS key ARN for ElastiCache encryption"
  type        = string
}

variable "replication_datalake_bucket_arn" {
  description = "ARN of destination bucket for data lake cross-region replication"
  type        = string
  default     = null
}

variable "replication_kms_key_arn" {
  description = "KMS key ARN in destination region for S3 replication"
  type        = string
  default     = null
}

variable "storage" {
  description = "Storage configuration parameters"
  type = object({
    datalake_bucket_name               = string
    audit_bucket_name                  = string
    model_artefacts_bucket_name        = string
    object_lock_retention_years        = optional(number, 7)
    cross_region_replication_enabled   = optional(bool, true)
    aurora_cluster_identifier          = string
    aurora_db_name                     = string
    aurora_master_username             = string
    aurora_instance_class              = optional(string, "db.r6g.large")
    aurora_multi_az_enabled            = optional(bool, true)
    aurora_backup_retention_days       = optional(number, 35)
    aurora_deletion_protection         = optional(bool, true)
    elasticache_cluster_id             = string
    elasticache_node_type              = optional(string, "cache.r7g.large")
    elasticache_multi_az_enabled       = optional(bool, true)
    elasticache_snapshot_retention_days = optional(number, 7)
  })
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
