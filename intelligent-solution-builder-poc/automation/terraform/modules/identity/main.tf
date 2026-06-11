###############################################################################
# Tier 2 Solution Module — Identity
# Composes the Cognito User Pool for ISB platform authentication and
# admin governance.
###############################################################################

module "cognito" {
  source = "../aws/cognito"

  user_pool_name   = var.user_pool_name
  user_pool_domain = var.user_pool_domain

  access_token_validity_hours = var.access_token_validity_hours
  callback_urls               = var.callback_urls
  logout_urls                 = var.logout_urls
  user_groups                 = var.user_groups

  common_tags = var.common_tags
}
