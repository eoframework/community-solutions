#------------------------------------------------------------------------------
# Security Module (Tier 2)
# Composes: aws/kms, aws/guardduty, aws/securityhub
# Manages: KMS keys, GuardDuty, Security Hub, preventative controls
#------------------------------------------------------------------------------

module "kms_primary" {
  source = "../aws/kms"

  key_alias           = "${var.name_prefix}-key-primary"
  description         = "Landing zone CMK for ${var.name_prefix} primary region"
  enable_key_rotation = var.kms_key_rotation_enabled
  common_tags         = var.common_tags
}

module "kms_secondary" {
  source = "../aws/kms"

  count               = var.enable_secondary_kms ? 1 : 0
  key_alias           = "${var.name_prefix}-key-secondary"
  description         = "Landing zone CMK for ${var.name_prefix} secondary region"
  enable_key_rotation = var.kms_key_rotation_enabled
  common_tags         = var.common_tags
}

module "guardduty" {
  source = "../aws/guardduty"

  enabled                    = var.guardduty_enabled
  detector_name              = "${var.name_prefix}-guardduty"
  delegated_admin_account_id = var.guardduty_delegated_admin_account_id
  enable_s3_logs             = true
  common_tags                = var.common_tags
}

module "securityhub" {
  source = "../aws/securityhub"

  region                     = var.region
  enable_fsbp                = var.securityhub_fsbp_enabled
  enable_nist                = var.securityhub_nist_enabled
  delegated_admin_account_id = var.securityhub_delegated_admin_account_id
}
