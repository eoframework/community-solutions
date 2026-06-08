output "primary_endpoint" {
  description = "ElastiCache Redis primary endpoint address"
  value       = module.elasticache.primary_endpoint
}

output "port" {
  description = "Redis port"
  value       = module.elasticache.port
}

output "security_group_id" {
  description = "Security group ID for the ElastiCache cluster"
  value       = module.elasticache.security_group_id
}

output "replication_group_id" {
  description = "ElastiCache replication group ID"
  value       = module.elasticache.replication_group_id
}
