#------------------------------------------------------------------------------
# Tier 1: AWS Secrets Manager — GitHub PAT and Cognito client secret
# Values are NOT set here — populated post-provisioning via CLI or CI/CD
# Automatic rotation schedules configured per SOW: 90-day PAT, 365-day Cognito
#------------------------------------------------------------------------------

# GitHub PAT secret — retrieved at runtime by Code Generator agent
resource "aws_secretsmanager_secret" "github_pat" {
  name        = var.github_pat_secret_name
  description = "GitHub Personal Access Token for automated artifact commits — rotated every 90 days"
  kms_key_id  = var.kms_key_arn

  recovery_window_in_days = 7

  tags = merge(var.common_tags, {
    Name        = var.github_pat_secret_name
    RotationDays = "90"
  })
}

# Cognito App Client secret — used by CLI credential refresh flow
resource "aws_secretsmanager_secret" "cognito_secret" {
  name        = var.cognito_secret_name
  description = "Cognito App Client secret for server-side auth flows — rotated every 365 days"
  kms_key_id  = var.kms_key_arn

  recovery_window_in_days = 7

  tags = merge(var.common_tags, {
    Name        = var.cognito_secret_name
    RotationDays = "365"
  })
}
