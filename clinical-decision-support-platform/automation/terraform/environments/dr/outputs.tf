################################################################################
# DR Environment — Outputs
################################################################################

output "vpc_id" {
  description = "DR VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "DR VPC CIDR"
  value       = module.networking.vpc_cidr
}

output "kms_aurora_key_arn" {
  description = "KMS key ARN for Aurora (DR region)"
  value       = module.security.kms_aurora_key_arn
}

output "kms_s3_datalake_key_arn" {
  description = "KMS key ARN for S3 data lake (DR region)"
  value       = module.security.kms_s3_datalake_key_arn
}

output "datalake_bucket_id" {
  description = "Data lake S3 bucket name (DR region)"
  value       = module.storage.datalake_bucket_id
}

output "aurora_cluster_endpoint" {
  description = "Aurora writer endpoint (DR region)"
  value       = module.storage.aurora_cluster_endpoint
}

output "elasticache_primary_endpoint" {
  description = "ElastiCache Redis primary endpoint (DR region)"
  value       = module.storage.elasticache_primary_endpoint
}

output "alb_dashboard_dns_name" {
  description = "Dashboard ALB DNS name (DR region)"
  value       = module.compute.alb_dashboard_dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name (DR region)"
  value       = module.compute.ecs_cluster_name
}

output "kinesis_stream_arn" {
  description = "Kinesis stream ARN (DR region)"
  value       = module.ingestion.kinesis_stream_arn
}

output "sns_alarms_topic_arn" {
  description = "SNS alarms topic ARN (DR region)"
  value       = module.monitoring.sns_topic_arn
}

output "sagemaker_execution_role_arn" {
  description = "SageMaker execution role ARN (DR region)"
  value       = module.ml_platform.sagemaker_execution_role_arn
}
