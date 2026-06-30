################################################################################
# Production Environment — Outputs
################################################################################

output "vpc_id" {
  description = "Production VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "Production VPC CIDR"
  value       = module.networking.vpc_cidr
}

output "app_subnet_ids" {
  description = "Private application subnet IDs"
  value       = module.networking.app_subnet_ids
}

output "data_subnet_ids" {
  description = "Private data subnet IDs"
  value       = module.networking.data_subnet_ids
}

output "kms_healthlake_key_arn" {
  description = "KMS key ARN for HealthLake"
  value       = module.security.kms_healthlake_key_arn
}

output "kms_aurora_key_arn" {
  description = "KMS key ARN for Aurora PostgreSQL"
  value       = module.security.kms_aurora_key_arn
}

output "kms_s3_datalake_key_arn" {
  description = "KMS key ARN for S3 data lake"
  value       = module.security.kms_s3_datalake_key_arn
}

output "kms_s3_audit_key_arn" {
  description = "KMS key ARN for S3 audit bucket"
  value       = module.security.kms_s3_audit_key_arn
}

output "kms_elasticache_key_arn" {
  description = "KMS key ARN for ElastiCache"
  value       = module.security.kms_elasticache_key_arn
}

output "kms_ebs_key_arn" {
  description = "KMS key ARN for EBS volumes"
  value       = module.security.kms_ebs_key_arn
}

output "waf_web_acl_arn" {
  description = "WAF WebACL ARN"
  value       = module.security.waf_web_acl_arn
}

output "datalake_bucket_id" {
  description = "Data lake S3 bucket name"
  value       = module.storage.datalake_bucket_id
}

output "audit_bucket_id" {
  description = "Audit S3 bucket name"
  value       = module.storage.audit_bucket_id
}

output "models_bucket_id" {
  description = "Model artefacts S3 bucket name"
  value       = module.storage.models_bucket_id
}

output "aurora_cluster_endpoint" {
  description = "Aurora writer endpoint"
  value       = module.storage.aurora_cluster_endpoint
}

output "aurora_reader_endpoint" {
  description = "Aurora reader endpoint"
  value       = module.storage.aurora_reader_endpoint
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

output "alb_fhir_dns_name" {
  description = "FHIR inbound ALB DNS name"
  value       = module.compute.alb_fhir_dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.compute.ecs_cluster_name
}

output "sagemaker_execution_role_arn" {
  description = "SageMaker execution role ARN"
  value       = module.ml_platform.sagemaker_execution_role_arn
}

output "model_registry_name" {
  description = "SageMaker Model Registry name"
  value       = module.ml_platform.model_registry_name
}

output "sns_alarms_topic_arn" {
  description = "SNS alarms topic ARN"
  value       = module.monitoring.sns_topic_arn
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = module.security.guardduty_detector_id
}
