#------------------------------------------------------------------------------
# DR Environment Outputs
# AWS Multi-Account Landing Zone
#------------------------------------------------------------------------------

output "governance_ou_ids" {
  description = "Map of Organizational Unit names to IDs"
  value       = module.governance.ou_ids
}

output "governance_policy_ids" {
  description = "Map of SCP/RCP policy keys to IDs"
  value       = module.governance.policy_ids
}

output "governance_permission_set_arns" {
  description = "Map of IAM Identity Center permission set keys to ARNs"
  value       = module.governance.permission_set_arns
}

output "security_kms_key_arn_primary" {
  description = "ARN of the DR region customer-managed KMS key"
  value       = module.security.kms_key_arn_primary
  sensitive   = true
}

output "security_guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = module.security.guardduty_detector_id
}

output "logging_log_archive_bucket_arn" {
  description = "ARN of the DR Log Archive S3 bucket"
  value       = module.logging.log_archive_bucket_arn
}

output "logging_cloudtrail_arn" {
  description = "ARN of the DR region CloudTrail trail"
  value       = module.logging.cloudtrail_arn
}

output "monitoring_sns_topic_arn_critical" {
  description = "ARN of the CRITICAL severity SNS topic"
  value       = module.monitoring.sns_topic_arn_critical
  sensitive   = true
}

output "monitoring_sns_topic_arn_high" {
  description = "ARN of the HIGH severity SNS topic"
  value       = module.monitoring.sns_topic_arn_high
  sensitive   = true
}

output "monitoring_sns_topic_arn_medium" {
  description = "ARN of the MEDIUM severity SNS topic"
  value       = module.monitoring.sns_topic_arn_medium
  sensitive   = true
}

output "aft_state_bucket_id" {
  description = "Name of the AFT Terraform state S3 bucket (DR region)"
  value       = module.aft.aft_state_bucket_id
}

output "aft_lock_table_name" {
  description = "Name of the AFT DynamoDB state lock table (DR region)"
  value       = module.aft.aft_lock_table_name
}

output "environment" {
  description = "Deployment environment name"
  value       = local.environment
}

output "dr_rto_landing_zone_hours" {
  description = "Recovery Time Objective for landing zone rebuild (hours)"
  value       = var.dr.rto_landing_zone_hours
}

output "dr_rpo_log_archive_minutes" {
  description = "Recovery Point Objective for Log Archive S3 CRR (minutes)"
  value       = var.dr.rpo_log_archive_minutes
}
