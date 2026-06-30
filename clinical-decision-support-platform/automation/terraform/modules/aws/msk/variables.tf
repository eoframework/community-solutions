variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "cluster_name" {
  description = "MSK cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for MSK brokers (one per AZ)"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to MSK"
  type        = list(string)
  default     = []
}

variable "broker_count" {
  description = "Number of MSK brokers"
  type        = number
  default     = 3
}

variable "broker_instance_type" {
  description = "MSK broker instance type"
  type        = string
  default     = "kafka.m5.large"
}

variable "broker_volume_size_gb" {
  description = "EBS volume size in GB per broker"
  type        = number
  default     = 200
}

variable "kafka_version" {
  description = "Apache Kafka version"
  type        = string
  default     = "3.5.1"
}

variable "kms_key_arn" {
  description = "KMS key ARN for broker EBS encryption"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
