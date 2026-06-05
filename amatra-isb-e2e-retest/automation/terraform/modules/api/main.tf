#------------------------------------------------------------------------------
# API Module - Tier 2 Solution Module
# Composes API Gateway HTTP API v2 and SQS DLQ for GitHub push failures
# Lambda route integrations are wired in environments/*/main.tf INTEGRATIONS
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# CloudWatch Log Group for API Access Logs
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "api_access" {
  name              = "/eofw/${var.environment}/apigw/access-logs"
  retention_in_days = var.log_retention_days

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# API Gateway HTTP API v2
#------------------------------------------------------------------------------
module "api_gateway" {
  source = "../aws/api-gateway"

  name_prefix           = var.name_prefix
  description           = "EO Framework HTTP API v2 — 11 Lambda routes"
  region                = var.region
  cognito_user_pool_id  = var.cognito_user_pool_id
  cognito_app_client_id = var.cognito_app_client_id
  cors_allow_origins    = var.cors_allow_origins
  throttle_burst_limit  = var.throttle_burst_limit
  throttle_rate_limit   = var.throttle_rate_limit

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# SQS FIFO DLQ for failed GitHub push messages
#------------------------------------------------------------------------------
module "github_dlq" {
  source = "../aws/sqs"

  queue_name                  = var.github_dlq_name
  fifo_queue                  = true
  content_based_deduplication = false
  visibility_timeout_seconds  = 300
  message_retention_seconds   = 1209600

  common_tags = var.common_tags
}
