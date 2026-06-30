output "primary_endpoint" {
  description = "Redis primary endpoint address"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint" {
  description = "Redis reader endpoint address"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "replication_group_id" {
  description = "Replication group ID"
  value       = aws_elasticache_replication_group.this.replication_group_id
}

output "security_group_id" {
  description = "Redis security group ID"
  value       = aws_security_group.redis.id
}

output "port" {
  description = "Redis port"
  value       = aws_elasticache_replication_group.this.port
}
