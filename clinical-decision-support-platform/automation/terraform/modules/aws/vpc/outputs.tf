output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = values(aws_subnet.public)[*].id
}

output "app_subnet_ids" {
  description = "Private application subnet IDs"
  value       = values(aws_subnet.app)[*].id
}

output "data_subnet_ids" {
  description = "Private data subnet IDs"
  value       = values(aws_subnet.data)[*].id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.this.id
}

output "endpoint_security_group_id" {
  description = "Security group ID for VPC endpoints"
  value       = aws_security_group.endpoints.id
}
