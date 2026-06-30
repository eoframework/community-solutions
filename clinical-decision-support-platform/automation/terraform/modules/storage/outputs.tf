output "datalake_bucket_id" {
  description = "Data lake S3 bucket name"
  value       = module.s3_datalake.bucket_id
}

output "datalake_bucket_arn" {
  description = "Data lake S3 bucket ARN"
  value       = module.s3_datalake.bucket_arn
}

output "audit_bucket_id" {
  description = "Audit S3 bucket name"
  value       = module.s3_audit.bucket_id
}

output "audit_bucket_arn" {
  description = "Audit S3 bucket ARN"
  value       = module.s3_audit.bucket_arn
}

output "models_bucket_id" {
  description = "Model artefacts S3 bucket name"
  value       = module.s3_models.bucket_id
}

output "models_bucket_arn" {
  description = "Model artefacts S3 bucket ARN"
  value       = module.s3_models.bucket_arn
}

output "aurora_cluster_id" {
  description = "Aurora cluster identifier"
  value       = module.aurora.cluster_id
}

output "aurora_cluster_endpoint" {
  description = "Aurora writer endpoint"
  value       = module.aurora.cluster_endpoint
}

output "aurora_reader_endpoint" {
  description = "Aurora reader endpoint"
  value       = module.aurora.reader_endpoint
}

output "aurora_security_group_id" {
  description = "Aurora security group ID"
  value       = module.aurora.security_group_id
}

output "elasticache_primary_endpoint" {
  description = "ElastiCache Redis primary endpoint"
  value       = module.elasticache.primary_endpoint
}

output "elasticache_reader_endpoint" {
  description = "ElastiCache Redis reader endpoint"
  value       = module.elasticache.reader_endpoint
}

output "elasticache_security_group_id" {
  description = "ElastiCache security group ID"
  value       = module.elasticache.security_group_id
}
