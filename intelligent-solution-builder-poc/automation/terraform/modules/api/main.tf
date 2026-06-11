###############################################################################
# Tier 2 Solution Module — API
# Composes the API Gateway REST API and Cognito authoriser for the ISB
# platform, then deploys the API with a stage.
###############################################################################

module "api_gateway" {
  source = "../aws/api-gateway"

  api_name              = var.api_name
  api_description       = "Amatra Intelligent Solution Builder REST API — ${var.environment}"
  cognito_user_pool_arn = var.cognito_user_pool_arn
  kms_key_arn           = var.kms_audit_key_arn
  log_retention_days    = var.log_retention_days
  common_tags           = var.common_tags
}
