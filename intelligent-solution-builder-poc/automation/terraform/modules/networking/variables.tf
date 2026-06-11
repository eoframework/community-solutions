variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (one per AZ)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (one per AZ)"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways"
  type        = number
  default     = 1
}

variable "enable_privatelink_endpoints" {
  description = "Deploy PrivateLink interface endpoints"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
