variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the Network Account inspection VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "vpc_endpoint_services" {
  description = "List of AWS service names for interface VPC endpoints"
  type        = list(string)
  default     = []
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to deploy (1 for test, 2 for prod/DR HA)"
  type        = number
  default     = 1
  validation {
    condition     = var.nat_gateway_count >= 1 && var.nat_gateway_count <= 3
    error_message = "nat_gateway_count must be between 1 and 3."
  }
}

variable "firewall_inspection_enabled" {
  description = "Deploy AWS Network Firewall subnets"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
