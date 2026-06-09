#------------------------------------------------------------------------------
# Tier 2: DR — Cross-region backup vault and S3 CRR replication configuration
# Provides warm-standby DR capability; RTO < 4h / RPO < 1h
# providers.tf required: module accepts aws.dr alias for DR region resources
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# AWS Backup vault in DR region — receives cross-region copies from primary
#------------------------------------------------------------------------------
resource "aws_backup_vault" "dr" {
  provider    = aws.dr
  name        = "${var.name_prefix}-dr-vault"
  kms_key_arn = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-dr-vault"
    Purpose = "dr-backup-vault"
    Standby = "true"
  })
}

#------------------------------------------------------------------------------
# CloudWatch alarm: S3 CRR replication lag sentinel (RPO guard)
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "rpo_guard" {
  alarm_name          = "${var.name_prefix}-dr-rpo-guard"
  alarm_description   = "P1: S3 CRR replication lag exceeds RPO target (${var.rpo_hours}h)"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReplicationLatency"
  namespace           = "AWS/S3"
  period              = 300
  statistic           = "Maximum"
  threshold           = var.rpo_hours * 3600
  treat_missing_data  = "notBreaching"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-dr-rpo-guard"
    Purpose = "dr-monitoring"
  })
}

#------------------------------------------------------------------------------
# SSM Parameter — DR metadata for runbook reference
#------------------------------------------------------------------------------
resource "aws_ssm_parameter" "dr_metadata" {
  name        = "/${var.name_prefix}/dr/metadata"
  type        = "String"
  description = "DR configuration metadata for runbook and failover automation"

  value = jsonencode({
    rto_hours                   = var.rto_hours
    rpo_hours                   = var.rpo_hours
    failover_activation_minutes = var.failover_activation_minutes
    dr_region                   = var.dr_region
    dr_vault_arn                = aws_backup_vault.dr.arn
    log_archive_bucket          = var.log_archive_bucket_name
  })

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-dr-metadata"
    Purpose = "dr-configuration"
  })
}
