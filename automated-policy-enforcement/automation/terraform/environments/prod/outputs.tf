#------------------------------------------------------------------------------
# AWS Cloud Governance Platform — Production Outputs
#------------------------------------------------------------------------------

output "kms_key_arn" {
  description = "ARN of the KMS CMK used to encrypt all platform data stores"
  value       = module.kms.key_arn
  sensitive   = false
}

output "kms_key_id" {
  description = "ID of the KMS CMK"
  value       = module.kms.key_id
  sensitive   = false
}

output "vpc_id" {
  description = "ID of the Network Account inspection VPC"
  value       = module.networking.vpc_id
}

output "vpc_private_subnet_ids" {
  description = "Private subnet IDs in the Network Account VPC"
  value       = module.networking.private_subnet_ids
}

output "log_archive_bucket_name" {
  description = "Name of the centralised S3 log archive bucket (CloudTrail + Config + Security Hub)"
  value       = module.storage.log_archive_bucket_name
}

output "log_archive_bucket_arn" {
  description = "ARN of the centralised S3 log archive bucket"
  value       = module.storage.log_archive_bucket_arn
}

output "crr_destination_bucket_name" {
  description = "Name of the S3 CRR destination bucket in ap-southeast-4 (DR)"
  value       = module.storage.crr_destination_bucket_name
}

output "tf_state_bucket_name" {
  description = "Name of the Terraform state S3 bucket in Management account"
  value       = module.storage.tf_state_bucket_name
}

output "aft_workflow_table_name" {
  description = "Name of the DynamoDB table storing AFT account vending workflow state"
  value       = module.database.aft_workflow_table_name
}

output "tf_state_lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  value       = module.database.tf_state_lock_table_name
}

output "aft_pipeline_name" {
  description = "Name of the AFT account vending CodePipeline"
  value       = module.aft_pipeline.pipeline_name
}

output "siem_forward_lambda_arn" {
  description = "ARN of the SIEM forwarding Lambda function"
  value       = module.siem_integration.lambda_arn
}

output "siem_dlq_url" {
  description = "URL of the SIEM forwarding dead-letter queue"
  value       = module.siem_integration.dlq_url
}

output "siem_dlq_arn" {
  description = "ARN of the SIEM forwarding dead-letter queue"
  value       = module.siem_integration.dlq_arn
}

output "itsm_integration_lambda_arn" {
  description = "ARN of the ITSM change-approval integration Lambda function"
  value       = module.itsm_integration.lambda_arn
}

output "config_remediation_lambda_arn" {
  description = "ARN of the Config auto-remediation Lambda function"
  value       = module.config_remediation.lambda_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic routing P1/P2 CloudWatch alarms to on-call engineer"
  value       = module.monitoring.sns_topic_arn
}

output "environment" {
  description = "Deployed environment name"
  value       = local.environment
}

output "name_prefix" {
  description = "Resource name prefix used across all platform resources"
  value       = local.name_prefix
}
