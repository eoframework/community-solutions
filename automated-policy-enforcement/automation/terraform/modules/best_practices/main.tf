#------------------------------------------------------------------------------
# Tier 2: Best Practices — AWS Backup, GuardDuty, Security Hub standards
# Calls Tier 1 AWS primitives for backup vaults and plans
# providers.tf required: module accepts aws.dr alias for cross-region backup
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# AWS Backup — daily plan with optional cross-region replication to DR
#------------------------------------------------------------------------------
resource "aws_backup_vault" "main" {
  name        = "${var.name_prefix}-backup-vault"
  kms_key_arn = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-backup-vault"
    Purpose = "platform-backup"
  })
}

resource "aws_backup_plan" "daily" {
  name = var.backup_plan_name

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 * * ? *)"
    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after = var.backup_retention_days
    }

    dynamic "copy_action" {
      for_each = var.backup_dr_replication_enabled ? [1] : []
      content {
        destination_vault_arn = aws_backup_vault.dr[0].arn
        lifecycle {
          delete_after = var.backup_retention_days
        }
      }
    }
  }

  tags = merge(var.common_tags, {
    Name    = var.backup_plan_name
    Purpose = "platform-backup"
  })
}

resource "aws_backup_vault" "dr" {
  count    = var.backup_dr_replication_enabled ? 1 : 0
  provider = aws.dr

  name        = "${var.name_prefix}-dr-backup-vault"
  kms_key_arn = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-dr-backup-vault"
    Purpose = "dr-backup-vault"
  })
}

#------------------------------------------------------------------------------
# AWS Backup selection — tags all resources with BackupPolicy=daily-30d
#------------------------------------------------------------------------------
resource "aws_backup_selection" "platform" {
  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.name_prefix}-backup-selection"
  plan_id      = aws_backup_plan.daily.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "BackupPolicy"
    value = "daily-30d"
  }
}

resource "aws_iam_role" "backup" {
  name        = "${var.name_prefix}-backup-role"
  description = "IAM role for AWS Backup service — platform state backup"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "backup.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-backup-role"
    Purpose = "aws-backup"
  })
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

#------------------------------------------------------------------------------
# GuardDuty — organisational detector (enabled in prod/dr; optional in test)
#------------------------------------------------------------------------------
resource "aws_guardduty_detector" "main" {
  count  = var.guardduty_enabled ? 1 : 0
  enable = true

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-guardduty"
    Purpose = "threat-detection"
  })
}

#------------------------------------------------------------------------------
# Security Hub — enable FSBP and CIS standards
#------------------------------------------------------------------------------
resource "aws_securityhub_account" "main" {
  enable_default_standards = false
}

resource "aws_securityhub_standards_subscription" "fsbp" {
  count         = var.securityhub_fsbp_enabled ? 1 : 0
  standards_arn = "arn:aws:securityhub:::ruleset/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [aws_securityhub_account.main]
}

resource "aws_securityhub_standards_subscription" "cis" {
  count         = var.securityhub_cis_enabled ? 1 : 0
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"

  depends_on = [aws_securityhub_account.main]
}
