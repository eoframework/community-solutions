variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets"
  type        = list(string)
}

variable "data_subnet_cidrs" {
  description = "CIDR blocks for private data subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to provision"
  type        = number
  default     = 2
}

variable "flow_log_retention_days" {
  description = "CloudWatch Log retention days for VPC flow logs"
  type        = number
  default     = 90
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting CloudWatch Logs"
  type        = string
  default     = null
}

variable "enable_privatelink" {
  description = "Enable VPC Interface Endpoints (PrivateLink) for AWS services"
  type        = bool
  default     = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
