#------------------------------------------------------------------------------
# Tier 2: Security Module
# Composes: WAF WebACL + CloudTrail audit trail
#------------------------------------------------------------------------------

module "waf" {
  source = "../aws/waf"
  count  = var.waf_managed_rules_enabled ? 1 : 0

  name_prefix                               = var.name_prefix
  rate_limit_requests_per_ip_per_5_minutes  = var.waf_rate_limit_requests_per_ip_per_minute * 5
  common_tags                               = var.common_tags
}

module "cloudtrail" {
  source = "../aws/cloudtrail"
  count  = var.cloudtrail_enabled ? 1 : 0

  name_prefix                   = var.name_prefix
  cloudtrail_s3_bucket_name     = var.cloudtrail_s3_bucket_name
  cloudtrail_log_retention_days = var.cloudtrail_log_retention_days
  aws_region                    = var.aws_region
  aws_account_id                = var.aws_account_id
  common_tags                   = var.common_tags
}
