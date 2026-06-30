variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "app_subnet_ids" {
  description = "Application subnet IDs for MSK brokers"
  type        = list(string)
}

variable "app_security_group_ids" {
  description = "Application security group IDs allowed to connect to MSK"
  type        = list(string)
  default     = []
}

variable "kms_key_id" {
  description = "KMS key ID for Kinesis stream encryption"
  type        = string
}

variable "kms_ebs_key_arn" {
  description = "KMS key ARN for MSK broker EBS encryption"
  type        = string
}

variable "ingestion" {
  description = "Ingestion pipeline configuration"
  type = object({
    kinesis_stream_name      = string
    kinesis_shard_count      = optional(number, 10)
    kinesis_retention_hours  = optional(number, 24)
    msk_cluster_name         = string
    msk_broker_count         = optional(number, 3)
    msk_broker_instance_type = optional(string, "kafka.m5.large")
  })
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
