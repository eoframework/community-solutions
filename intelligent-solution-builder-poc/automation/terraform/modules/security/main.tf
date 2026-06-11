###############################################################################
# Tier 2 Solution Module — Security
# Composes AWS KMS (4 CMKs) and WAF for the ISB platform.
# All KMS keys follow the amatra data classification tier design.
###############################################################################

module "kms_artifacts" {
  source      = "../aws/kms"
  name_prefix = var.name_prefix
  key_purpose = "artifacts"
  description = "Amatra ISB — S3 artifact bucket SSE-KMS encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  common_tags             = var.common_tags
}

module "kms_database" {
  source      = "../aws/kms"
  name_prefix = var.name_prefix
  key_purpose = "database"
  description = "Amatra ISB — DynamoDB table encryption at rest"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  common_tags             = var.common_tags
}

module "kms_secrets" {
  source      = "../aws/kms"
  name_prefix = var.name_prefix
  key_purpose = "secrets"
  description = "Amatra ISB — Secrets Manager secret encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  common_tags             = var.common_tags
}

module "kms_audit" {
  source      = "../aws/kms"
  name_prefix = var.name_prefix
  key_purpose = "audit"
  description = "Amatra ISB — CloudTrail logs and CloudWatch Logs encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  common_tags             = var.common_tags
}

module "waf" {
  count       = var.enable_waf ? 1 : 0
  source      = "../aws/waf"
  name_prefix = var.name_prefix
  rate_limit_requests_per_5_min = var.waf_rate_limit_per_5_min
  log_retention_days            = var.log_retention_days
  common_tags                   = var.common_tags
}
