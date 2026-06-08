variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_az1" {
  description = "CIDR block for public subnet in AZ1"
  type        = string
}

variable "public_subnet_az2" {
  description = "CIDR block for public subnet in AZ2"
  type        = string
}

variable "private_subnet_app_az1" {
  description = "CIDR block for private application subnet in AZ1"
  type        = string
}

variable "private_subnet_app_az2" {
  description = "CIDR block for private application subnet in AZ2"
  type        = string
}

variable "private_subnet_data_az1" {
  description = "CIDR block for private data subnet in AZ1"
  type        = string
}

variable "private_subnet_data_az2" {
  description = "CIDR block for private data subnet in AZ2"
  type        = string
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create"
  type        = number
  default     = 1
}

variable "vpc_gateway_endpoints" {
  description = "List of AWS services for VPC Gateway Endpoints (S3, DynamoDB)"
  type        = list(string)
  default     = ["S3", "DynamoDB"]
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
