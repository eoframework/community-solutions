#------------------------------------------------------------------------------
# AWS Cloud Governance Platform — DR Outputs
#------------------------------------------------------------------------------

output "kms_key_arn" {
  description = "ARN of the KMS CMK in the DR region (ap-southeast-4)"
  value       = module.kms.key_arn
  sensitive   = false
}

output "kms_key_id" {
  description = "ID of the KMS CMK in DR region"
  value       = module.kms.key_id
  sensitive   = false
}

output "vpc_id" {
  description = "ID of the DR region inspection VPC"
  value       = module.networking.vpc_id
}

output "vpc_private_subnet_ids" {
  description = "Private subnet IDs in the DR region VPC"
  value       = module.networking.private_subnet_ids
}

output "log_archive_bucket_name" {
  description = "Name of the DR S3 log archive bucket (CRR destination)"
  value       = module.storage.log_archive_bucket_name
}

output "log_archive_bucket_arn" {
  description = "ARN of the DR S3 log archive bucket"
  value       = module.storage.log_archive_bucket_arn
}

output "crr_destination_bucket_name" {
  description = "CRR destination bucket name (DR region)"
  value       = module.storage.crr_destination_bucket_name
}

output "tf_state_bucket_name" {
  description = "Name of the Terraform state bucket in DR region"
  value       = module.storage.tf_state_bucket_name
}

output "aft_workflow_table_name" {
  description = "Name of the AFT workflow DynamoDB table in DR region"
  value       = module.database.aft_workflow_table_name
}

output "tf_state_lock_table_name" {
  description = "Name of the Terraform state lock DynamoDB table in DR region"
  value       = module.database.tf_state_lock_table_name
}

output "aft_pipeline_name" {
  description = "Name of the AFT CodePipeline in DR region"
  value       = module.aft_pipeline.pipeline_name
}

output "siem_forward_lambda_arn" {
  description = "ARN of the SIEM forwarding Lambda in DR region"
  value       = module.siem_integration.lambda_arn
}

output "siem_dlq_url" {
  description = "URL of the SIEM forwarding DLQ in DR region"
  value       = module.siem_integration.dlq_url
}

output "siem_dlq_arn" {
  description = "ARN of the SIEM forwarding DLQ in DR region"
  value       = module.siem_integration.dlq_arn
}

output "itsm_integration_lambda_arn" {
  description = "ARN of the ITSM integration Lambda in DR region"
  value       = module.itsm_integration.lambda_arn
}

output "config_remediation_lambda_arn" {
  description = "ARN of the Config auto-remediation Lambda in DR region"
  value       = module.config_remediation.lambda_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS alerting topic in DR region"
  value       = module.monitoring.sns_topic_arn
}

output "dr_backup_vault_arn" {
  description = "ARN of the AWS Backup vault in the DR region (receives cross-region copies)"
  value       = module.dr.backup_vault_arn
}

output "environment" {
  description = "Deployed environment name"
  value       = local.environment
}

output "name_prefix" {
  description = "Resource name prefix (DR)"
  value       = local.name_prefix
}
