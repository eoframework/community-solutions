#------------------------------------------------------------------------------
# Security Module - Tier 2 Solution Module
# Composes KMS, Cognito, GuardDuty, IAM Access Analyzer, and Security Hub
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# KMS Customer Managed Key for S3 artifact bucket encryption
#------------------------------------------------------------------------------
module "kms_s3" {
  source = "../aws/kms"

  name_prefix             = var.name_prefix
  description             = "CMK for EO Framework S3 artifact bucket SSE-KMS encryption"
  key_alias_suffix        = "s3-artifacts"
  deletion_window_in_days = 30
  rotation_period_in_days = var.security.kms_rotation_days

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# Cognito User Pool for JWT authentication
#------------------------------------------------------------------------------
module "cognito" {
  source = "../aws/cognito"

  user_pool_name              = var.security.cognito_user_pool_name
  mfa_enabled                 = var.security.cognito_mfa_enabled
  post_confirmation_lambda_arn = var.cognito_post_confirmation_lambda_arn
  access_token_expiry_seconds  = var.security.cognito_access_token_expiry_seconds
  refresh_token_expiry_days    = var.security.cognito_refresh_token_expiry_days

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# IAM Access Analyzer
#------------------------------------------------------------------------------
resource "aws_accessanalyzer_analyzer" "main" {
  count         = var.security.access_analyzer_enabled ? 1 : 0
  analyzer_name = "${var.name_prefix}-access-analyzer"
  type          = "ACCOUNT"

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# GuardDuty
#------------------------------------------------------------------------------
resource "aws_guardduty_detector" "main" {
  count  = var.security.guardduty_enabled ? 1 : 0
  enable = true

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Security Hub
#------------------------------------------------------------------------------
resource "aws_securityhub_account" "main" {
  count = var.security.securityhub_enabled ? 1 : 0
}

resource "aws_securityhub_standards_subscription" "aws_foundational" {
  count         = var.security.securityhub_enabled ? 1 : 0
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [aws_securityhub_account.main]
}
