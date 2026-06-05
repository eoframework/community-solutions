variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "subnet_private_az1_cidr" {
  description = "Private subnet CIDR for AZ1"
  type        = string
}

variable "subnet_private_az2_cidr" {
  description = "Private subnet CIDR for AZ2"
  type        = string
}

variable "subnet_private_az3_cidr" {
  description = "Private subnet CIDR for AZ3"
  type        = string
}

variable "subnet_public_cidr" {
  description = "Public subnet CIDR for NAT Gateway"
  type        = string
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateway instances"
  type        = number
  default     = 1
}

variable "vpc_endpoints_enabled" {
  description = "Provision VPC interface endpoints for AWS services"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
