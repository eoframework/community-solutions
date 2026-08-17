#------------------------------------------------------------------------------
# Governance Module (Tier 2)
# Composes: aws/organizations, aws/sso
# Manages: OU hierarchy, SCPs, RCPs, IAM Identity Center permission sets
#------------------------------------------------------------------------------

module "organizations" {
  source = "../aws/organizations"

  organizational_units = var.organizational_units
  policies             = var.policies
  policy_attachments   = var.policy_attachments
  common_tags          = var.common_tags
}

module "sso" {
  source = "../aws/sso"

  sso_instance_arn           = var.sso_instance_arn
  permission_sets            = var.permission_sets
  managed_policy_attachments = var.managed_policy_attachments
  inline_policies            = var.inline_policies
  common_tags                = var.common_tags
}
