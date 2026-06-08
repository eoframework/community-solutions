variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "node_type" {
  description = "ElastiCache node instance type"
  type        = string
  default     = "cache.t3.micro"
}

variable "port" {
  description = "Redis port number"
  type        = number
  default     = 6379
}

variable "subnet_ids" {
  description = "Subnet IDs for the ElastiCache subnet group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "app_security_group_id" {
  description = "Application security group ID allowed inbound access to Redis"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for at-rest encryption"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
