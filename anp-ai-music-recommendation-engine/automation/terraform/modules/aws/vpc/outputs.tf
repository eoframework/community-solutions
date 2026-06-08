output "vpc_id" {
  description = "VPC identifier"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_az1_id" {
  description = "Public subnet ID in AZ1"
  value       = aws_subnet.public_az1.id
}

output "public_subnet_az2_id" {
  description = "Public subnet ID in AZ2"
  value       = aws_subnet.public_az2.id
}

output "private_subnet_app_az1_id" {
  description = "Private application subnet ID in AZ1"
  value       = aws_subnet.private_app_az1.id
}

output "private_subnet_app_az2_id" {
  description = "Private application subnet ID in AZ2"
  value       = aws_subnet.private_app_az2.id
}

output "private_subnet_data_az1_id" {
  description = "Private data subnet ID in AZ1"
  value       = aws_subnet.private_data_az1.id
}

output "private_subnet_data_az2_id" {
  description = "Private data subnet ID in AZ2"
  value       = aws_subnet.private_data_az2.id
}

output "private_subnet_app_ids" {
  description = "List of private application subnet IDs"
  value       = [aws_subnet.private_app_az1.id, aws_subnet.private_app_az2.id]
}

output "private_subnet_data_ids" {
  description = "List of private data subnet IDs"
  value       = [aws_subnet.private_data_az1.id, aws_subnet.private_data_az2.id]
}

output "internet_gateway_id" {
  description = "Internet Gateway identifier"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway identifiers"
  value       = aws_nat_gateway.main[*].id
}

output "private_route_table_az1_id" {
  description = "Private route table ID for AZ1"
  value       = aws_route_table.private_az1.id
}

output "private_route_table_az2_id" {
  description = "Private route table ID for AZ2"
  value       = aws_route_table.private_az2.id
}
