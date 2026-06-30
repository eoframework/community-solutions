output "kms_healthlake_key_arn" {
  description = "KMS key ARN for HealthLake"
  value       = module.kms_healthlake.key_arn
}

output "kms_aurora_key_arn" {
  description = "KMS key ARN for Aurora PostgreSQL"
  value       = module.kms_aurora.key_arn
}

output "kms_s3_datalake_key_arn" {
  description = "KMS key ARN for S3 data lake"
  value       = module.kms_s3_datalake.key_arn
}

output "kms_s3_audit_key_arn" {
  description = "KMS key ARN for S3 audit log bucket"
  value       = module.kms_s3_audit.key_arn
}

output "kms_elasticache_key_arn" {
  description = "KMS key ARN for ElastiCache Redis"
  value       = module.kms_elasticache.key_arn
}

output "kms_ebs_key_arn" {
  description = "KMS key ARN for EBS volumes"
  value       = module.kms_ebs.key_arn
}

output "waf_web_acl_arn" {
  description = "WAF WebACL ARN"
  value       = var.enable_waf ? aws_wafv2_web_acl.this[0].arn : null
}

output "waf_web_acl_id" {
  description = "WAF WebACL ID"
  value       = var.enable_waf ? aws_wafv2_web_acl.this[0].id : null
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = var.enable_guardduty ? aws_guardduty_detector.this[0].id : null
}

output "cloudtrail_log_group_name" {
  description = "CloudTrail CloudWatch log group name"
  value       = var.enable_cloudtrail ? aws_cloudwatch_log_group.cloudtrail[0].name : null
}
