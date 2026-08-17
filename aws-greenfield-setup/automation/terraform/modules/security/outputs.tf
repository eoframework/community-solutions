output "kms_key_id_primary" {
  description = "ID of the primary region KMS key"
  value       = module.kms_primary.key_id
}

output "kms_key_arn_primary" {
  description = "ARN of the primary region KMS key"
  value       = module.kms_primary.key_arn
}

output "kms_key_arn_secondary" {
  description = "ARN of the secondary region KMS key (null if not enabled)"
  value       = var.enable_secondary_kms ? module.kms_secondary[0].key_arn : null
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = module.guardduty.detector_id
}

output "guardduty_detector_arn" {
  description = "GuardDuty detector ARN"
  value       = module.guardduty.detector_arn
}

output "securityhub_enabled" {
  description = "Whether Security Hub has been enabled"
  value       = module.securityhub.securityhub_enabled
}
