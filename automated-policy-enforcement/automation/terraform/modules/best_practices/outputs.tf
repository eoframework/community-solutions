output "backup_vault_arn" {
  description = "ARN of the primary AWS Backup vault"
  value       = aws_backup_vault.main.arn
}

output "backup_plan_id" {
  description = "ID of the daily AWS Backup plan"
  value       = aws_backup_plan.daily.id
}

output "dr_backup_vault_arn" {
  description = "ARN of the DR region AWS Backup vault (empty string if DR replication disabled)"
  value       = var.backup_dr_replication_enabled ? aws_backup_vault.dr[0].arn : ""
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector (empty string if disabled)"
  value       = var.guardduty_enabled ? aws_guardduty_detector.main[0].id : ""
}

output "securityhub_account_id" {
  description = "AWS account ID enrolled in Security Hub"
  value       = aws_securityhub_account.main.id
}
