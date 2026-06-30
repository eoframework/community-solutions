################################################################################
# Test Environment — Outputs
################################################################################

output "vpc_id" {
  description = "Test VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "Test VPC CIDR"
  value       = module.networking.vpc_cidr
}

output "kms_aurora_key_arn" {
  description = "KMS key ARN for Aurora"
  value       = module.security.kms_aurora_key_arn
}

output "kms_s3_datalake_key_arn" {
  description = "KMS key ARN for S3 data lake"
  value       = module.security.kms_s3_datalake_key_arn
}

output "datalake_bucket_id" {
  description = "Data lake S3 bucket name"
  value       = module.storage.datalake_bucket_id
}

output "aurora_cluster_endpoint" {
  description = "Aurora writer endpoint"
  value       = module.storage.aurora_cluster_endpoint
}

output "elasticache_primary_endpoint" {
  description = "ElastiCache Redis primary endpoint"
  value       = module.storage.elasticache_primary_endpoint
}

output "kinesis_stream_arn" {
  description = "Kinesis stream ARN"
  value       = module.ingestion.kinesis_stream_arn
}

output "msk_bootstrap_brokers_tls" {
  description = "MSK TLS bootstrap brokers"
  value       = module.ingestion.msk_bootstrap_brokers_tls
}

output "alb_dashboard_dns_name" {
  description = "Dashboard ALB DNS name"
  value       = module.compute.alb_dashboard_dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.compute.ecs_cluster_name
}

output "sagemaker_execution_role_arn" {
  description = "SageMaker execution role ARN"
  value       = module.ml_platform.sagemaker_execution_role_arn
}

output "sns_alarms_topic_arn" {
  description = "SNS alarms topic ARN"
  value       = module.monitoring.sns_topic_arn
}
