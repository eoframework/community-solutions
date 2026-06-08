variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "instance_type" {
  description = "OpenSearch node instance type"
  type        = string
  default     = "t3.small.search"
}

variable "volume_gb" {
  description = "EBS volume size in GB for the OpenSearch node"
  type        = number
  default     = 20
}

variable "subnet_id" {
  description = "Subnet ID for the OpenSearch node (single-AZ)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID of the application tier (Lambda/SageMaker)"
  type        = string
}

variable "catalog_kms_key_arn" {
  description = "KMS key ARN for OpenSearch at-rest encryption"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
