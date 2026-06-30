output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "app_subnet_ids" {
  description = "Private application subnet IDs"
  value       = module.vpc.app_subnet_ids
}

output "data_subnet_ids" {
  description = "Private data subnet IDs"
  value       = module.vpc.data_subnet_ids
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "endpoint_security_group_id" {
  description = "Security group ID for VPC endpoints"
  value       = module.vpc.endpoint_security_group_id
}
