#------------------------------------------------------------------------------
# AWS Security Hub Tier-1 Module
# Enables Security Hub with FSBP standard
#------------------------------------------------------------------------------

resource "aws_securityhub_account" "this" {}

resource "aws_securityhub_standards_subscription" "fsbp" {
  count         = var.enable_fsbp ? 1 : 0
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "nist" {
  count         = var.enable_nist ? 1 : 0
  standards_arn = "arn:aws:securityhub:${var.region}::standards/nist-800-53/v/5.0.0"
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_organization_admin_account" "this" {
  count            = var.delegated_admin_account_id != null ? 1 : 0
  admin_account_id = var.delegated_admin_account_id
  depends_on       = [aws_securityhub_account.this]
}
