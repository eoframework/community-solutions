output "backup_vault_arn" {
  description = "ARN of the DR region AWS Backup vault"
  value       = aws_backup_vault.dr.arn
}

output "backup_vault_name" {
  description = "Name of the DR region AWS Backup vault"
  value       = aws_backup_vault.dr.name
}

output "rpo_guard_alarm_arn" {
  description = "ARN of the CloudWatch alarm monitoring S3 CRR lag against RPO target"
  value       = aws_cloudwatch_metric_alarm.rpo_guard.arn
}

output "dr_metadata_ssm_path" {
  description = "SSM Parameter Store path for DR metadata"
  value       = aws_ssm_parameter.dr_metadata.name
}
