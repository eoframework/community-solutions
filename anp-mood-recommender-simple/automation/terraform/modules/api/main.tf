#------------------------------------------------------------------------------
# API Module (Tier 2) - API Gateway REST API
# Calls: aws/api-gateway
#------------------------------------------------------------------------------

module "api_gateway" {
  source = "../aws/api-gateway"

  api_name        = var.api_name
  api_description = "ANP Streaming AI Mood & Recommendation API"
  stage_name      = var.stage_name

  rate_limit_rps = var.rate_limit_rps
  burst_limit    = var.burst_limit

  classifier_function_name  = var.classifier_function_name
  classifier_invoke_arn     = var.classifier_invoke_arn
  recommender_function_name = var.recommender_function_name
  recommender_invoke_arn    = var.recommender_invoke_arn

  cognito_user_pool_arn = var.cognito_user_pool_arn

  enable_xray        = var.enable_xray
  log_retention_days = var.log_retention_days
  common_tags        = var.common_tags
}
