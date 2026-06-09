#------------------------------------------------------------------------------
# AWS Cloud Governance Platform — Test Outputs
#------------------------------------------------------------------------------

output "kms_key_arn" {
  description = "ARN of the KMS CMK used to encrypt all platform data stores (test)"
  value       = module.kms.key_arn
  sensitive   = false
}

output "kms_key_id" {
  description = "ID of the KMS CMK (test)"
  value       = module.kms.key_id
  sensitive   = false
}

output "vpc_id" {
  description = "ID of the inspection VPC (test)"
  value       = module.networking.vpc_id
}

output "vpc_private_subnet_ids" {
  description = "Private subnet IDs (test)"
  value       = module.networking.private_subnet_ids
}

output "log_archive_bucket_name" {
  description = "Name of the S3 log archive bucket (test)"
  value       = module.storage.log_archive_bucket_name
}

output "log_archive_bucket_arn" {
  description = "ARN of the S3 log archive bucket (test)"
  value       = module.storage.log_archive_bucket_arn
}

output "crr_destination_bucket_name" {
  description = "Name of the S3 CRR destination bucket (test)"
  value       = module.storage.crr_destination_bucket_name
}

output "tf_state_bucket_name" {
  description = "Name of the Terraform state bucket (test)"
  value       = module.storage.tf_state_bucket_name
}

output "aft_workflow_table_name" {
  description = "Name of the AFT workflow DynamoDB table (test)"
  value       = module.database.aft_workflow_table_name
}

output "tf_state_lock_table_name" {
  description = "Name of the Terraform state lock DynamoDB table (test)"
  value       = module.database.tf_state_lock_table_name
}

output "aft_pipeline_name" {
  description = "Name of the AFT CodePipeline (test)"
  value       = module.aft_pipeline.pipeline_name
}

output "siem_forward_lambda_arn" {
  description = "ARN of the SIEM forwarding Lambda (test)"
  value       = module.siem_integration.lambda_arn
}

output "siem_dlq_url" {
  description = "URL of the SIEM forwarding DLQ (test)"
  value       = module.siem_integration.dlq_url
}

output "siem_dlq_arn" {
  description = "ARN of the SIEM forwarding DLQ (test)"
  value       = module.siem_integration.dlq_arn
}

output "itsm_integration_lambda_arn" {
  description = "ARN of the ITSM integration Lambda (test)"
  value       = module.itsm_integration.lambda_arn
}

output "config_remediation_lambda_arn" {
  description = "ARN of the Config auto-remediation Lambda (test)"
  value       = module.config_remediation.lambda_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS alerting topic (test)"
  value       = module.monitoring.sns_topic_arn
}

output "environment" {
  description = "Deployed environment name"
  value       = local.environment
}

output "name_prefix" {
  description = "Resource name prefix (test)"
  value       = local.name_prefix
}
