#------------------------------------------------------------------------------
# AWS Agentic Pre-Sales Orchestration Platform — DR Environment
# EO Framework | Solution: aws-agentic-presales | Environment: production (DR)
#------------------------------------------------------------------------------

locals {
  environment = "dr"
  name_prefix = "eofw-prd"

  common_tags = {
    Solution           = var.solution.name
    Environment        = "production"
    Application        = var.application.name
    ManagedBy          = "terraform"
    CostCenter         = var.solution.cost_center
    DataClassification = "PREDICTif-Internal"
    Compliance         = "SOC2-Readiness"
    Purpose            = "DisasterRecovery"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#===============================================================================
# FOUNDATION — Core infrastructure (DR mirrors prod; GuardDuty managed at prod)
#===============================================================================

module "security" {
  source = "../../modules/security"

  name_prefix = local.name_prefix
  region      = var.networking.region

  security = {
    cognito_user_pool_name              = var.security.cognito_user_pool_name
    cognito_mfa_enabled                 = var.security.cognito_mfa_enabled
    cognito_access_token_expiry_seconds = var.security.cognito_access_token_expiry_seconds
    cognito_refresh_token_expiry_days   = var.security.cognito_refresh_token_expiry_days
    kms_rotation_days                   = var.security.kms_rotation_days
    access_analyzer_enabled             = var.security.access_analyzer_enabled
    guardduty_enabled                   = false
    securityhub_enabled                 = false
  }

  cognito_post_confirmation_lambda_arn = ""

  common_tags = local.common_tags
}

module "networking" {
  source = "../../modules/networking"

  name_prefix = local.name_prefix
  region      = var.networking.region

  networking = {
    vpc_cidr              = var.networking.vpc_cidr
    public_subnet_cidrs   = var.networking.public_subnet_cidrs
    private_subnet_cidrs  = var.networking.private_subnet_cidrs
    database_subnet_cidrs = var.networking.database_subnet_cidrs
    availability_zones    = var.networking.availability_zones
    nat_gateway_count     = var.networking.nat_gateway_count
    vpc_endpoint_s3               = var.networking.vpc_endpoint_s3
    vpc_endpoint_dynamodb         = var.networking.vpc_endpoint_dynamodb
    vpc_endpoint_secrets_manager  = var.networking.vpc_endpoint_secrets_manager
    vpc_endpoint_bedrock_runtime  = var.networking.vpc_endpoint_bedrock_runtime
  }

  common_tags = local.common_tags

  depends_on = [module.security]
}

module "storage" {
  source = "../../modules/storage"

  name_prefix    = local.name_prefix
  kms_s3_key_arn = module.security.kms_s3_key_arn

  storage = {
    artifact_bucket_name               = var.storage.artifact_bucket_name
    guidance_bucket_name               = var.storage.guidance_bucket_name
    artifact_bucket_versioning_enabled = var.storage.artifact_bucket_versioning_enabled
    artifact_standard_retention_days   = var.storage.artifact_standard_retention_days
    artifact_glacier_retention_days    = var.storage.artifact_glacier_retention_days
  }

  force_destroy = false

  common_tags = local.common_tags

  depends_on = [module.security]
}

#===============================================================================
# CORE SOLUTION — Full production-equivalent DR components
#===============================================================================

module "database" {
  source = "../../modules/database"

  name_prefix = local.name_prefix

  database = {
    users_table_name        = var.database.users_table_name
    solutions_table_name    = var.database.solutions_table_name
    quotas_table_name       = var.database.quotas_table_name
    audit_events_table_name = var.database.audit_events_table_name
    billing_mode            = var.database.billing_mode
    pitr_enabled            = var.database.pitr_enabled
    audit_events_ttl_days   = var.database.audit_events_ttl_days
  }

  deletion_protection_enabled = true

  common_tags = local.common_tags

  depends_on = [module.networking]
}

module "api" {
  source = "../../modules/api"

  name_prefix        = local.name_prefix
  environment        = local.environment
  region             = var.networking.region
  log_retention_days = var.monitoring.log_retention_lambda_days

  cognito_user_pool_id  = module.security.cognito_user_pool_id
  cognito_app_client_id = module.security.cognito_app_client_id
  cors_allow_origins    = ["*"]
  throttle_burst_limit  = var.networking.apigw_throttle_rps_burst
  throttle_rate_limit   = var.networking.apigw_throttle_rps_burst / 2
  github_dlq_name       = var.integration.github_dlq_name

  common_tags = local.common_tags

  depends_on = [module.security, module.database]
}

module "compute" {
  source = "../../modules/compute"

  name_prefix        = local.name_prefix
  environment        = local.environment
  region             = var.networking.region
  log_level          = var.application.log_level
  log_retention_days = var.monitoring.log_retention_lambda_days
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  compute = {
    ecr_repository_name                  = var.compute.ecr_repository_name
    ecr_agent_image_uri                  = var.compute.ecr_agent_image_uri
    lambda_runtime                       = var.compute.lambda_runtime
    lambda_architecture                  = var.compute.lambda_architecture
    xray_tracing                         = var.compute.xray_tracing
    api_handler_memory_mb                = var.compute.api_handler_memory_mb
    api_handler_timeout_seconds          = var.compute.api_handler_timeout_seconds
    generation_initiator_memory_mb       = var.compute.generation_initiator_memory_mb
    generation_initiator_timeout_seconds = var.compute.generation_initiator_timeout_seconds
    agent_trigger_memory_mb              = var.compute.agent_trigger_memory_mb
    agent_trigger_timeout_seconds        = var.compute.agent_trigger_timeout_seconds
    cognito_trigger_memory_mb            = var.compute.cognito_trigger_memory_mb
    cognito_trigger_timeout_seconds      = var.compute.cognito_trigger_timeout_seconds
    github_push_memory_mb                = var.compute.github_push_memory_mb
    github_push_timeout_seconds          = var.compute.github_push_timeout_seconds
  }

  bedrock_region             = var.bedrock.agentcore_runtime_region
  bedrock_primary_model_id   = var.bedrock.primary_model_id
  bedrock_validator_model_id = var.bedrock.validator_model_id

  users_table_name        = module.database.users_table_name
  solutions_table_name    = module.database.solutions_table_name
  quotas_table_name       = module.database.quotas_table_name
  audit_events_table_name = module.database.audit_events_table_name

  dynamodb_table_arns = [
    module.database.users_table_arn,
    module.database.solutions_table_arn,
    module.database.quotas_table_arn,
    module.database.audit_events_table_arn
  ]

  artifact_bucket_name     = module.storage.artifact_bucket_id
  artifact_bucket_arn      = module.storage.artifact_bucket_arn
  guidance_bucket_name     = module.storage.guidance_bucket_id
  guidance_bucket_arn      = module.storage.guidance_bucket_arn
  github_secret_arn        = var.integration.github_secret_arn
  github_dlq_url           = module.api.github_dlq_url
  github_dlq_arn           = module.api.github_dlq_arn
  github_push_retry_count  = var.integration.github_push_retry_count
  quota_per_user_monthly   = var.database.quota_per_user_monthly
  quota_global_monthly     = var.database.quota_global_monthly
  max_retries_per_artifact = var.application.max_retries_per_artifact

  common_tags = local.common_tags

  depends_on = [module.networking, module.database, module.storage, module.api]
}

#===============================================================================
# OPERATIONS — DR monitoring and audit trail
#===============================================================================

module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix = local.name_prefix
  region      = var.networking.region

  monitoring = {
    cloudwatch_dashboard_name    = var.monitoring.cloudwatch_dashboard_name
    cloudtrail_bucket_name       = var.monitoring.cloudtrail_bucket_name
    cloudtrail_retention_days    = var.monitoring.cloudtrail_retention_days
    alarm_lambda_error_rate_pct  = var.monitoring.alarm_lambda_error_rate_pct
    alarm_bedrock_throttle_count = var.monitoring.alarm_bedrock_throttle_count
    api_gateway_p99_latency_ms   = var.monitoring.api_gateway_p99_latency_ms
    alert_email_subscriptions    = var.monitoring.alert_email_subscriptions
  }

  s3_data_events_enabled = var.monitoring.cloudtrail_s3_data_events
  artifact_bucket_arn    = module.storage.artifact_bucket_arn
  api_gateway_id         = module.api.api_id
  solutions_table_name   = module.database.solutions_table_name
  quotas_table_name      = module.database.quotas_table_name
  github_dlq_name        = var.integration.github_dlq_name

  common_tags = local.common_tags

  depends_on = [module.database, module.api, module.compute]
}

#===============================================================================
# INTEGRATIONS — Cross-module connections
#===============================================================================

resource "aws_apigatewayv2_integration" "generation_initiator" {
  api_id                 = module.api.api_id
  integration_type       = "AWS_PROXY"
  integration_uri        = module.compute.lambda_generation_initiator_invoke_arn
  payload_format_version = "2.0"

  depends_on = [module.api, module.compute]
}

resource "aws_apigatewayv2_route" "post_solutions" {
  api_id             = module.api.api_id
  route_key          = "POST /api/v1/solutions"
  target             = "integrations/${aws_apigatewayv2_integration.generation_initiator.id}"
  authorization_type = "JWT"
  authorizer_id      = module.api.authorizer_id
}

resource "aws_apigatewayv2_integration" "api_handler" {
  api_id                 = module.api.api_id
  integration_type       = "AWS_PROXY"
  integration_uri        = module.compute.lambda_api_handler_invoke_arn
  payload_format_version = "2.0"

  depends_on = [module.api, module.compute]
}

resource "aws_apigatewayv2_route" "get_solution" {
  api_id             = module.api.api_id
  route_key          = "GET /api/v1/solutions/{solution_id}"
  target             = "integrations/${aws_apigatewayv2_integration.api_handler.id}"
  authorization_type = "JWT"
  authorizer_id      = module.api.authorizer_id
}

resource "aws_apigatewayv2_route" "get_health" {
  api_id             = module.api.api_id
  route_key          = "GET /api/v1/health"
  target             = "integrations/${aws_apigatewayv2_integration.api_handler.id}"
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "generation_initiator_apigw" {
  statement_id  = "AllowAPIGWInvokeGenerationInitiatorDR"
  action        = "lambda:InvokeFunction"
  function_name = module.compute.lambda_generation_initiator_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api.execution_arn}/*/*"

  depends_on = [module.api, module.compute]
}

resource "aws_lambda_permission" "api_handler_apigw" {
  statement_id  = "AllowAPIGWInvokeApiHandlerDR"
  action        = "lambda:InvokeFunction"
  function_name = module.compute.lambda_api_handler_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api.execution_arn}/*/*"

  depends_on = [module.api, module.compute]
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_throttle" {
  alarm_name          = "${local.name_prefix}-dr-alarm-dynamodb-throttle"
  alarm_description   = "DR DynamoDB throttled requests on quota enforcement table"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = module.database.quotas_table_name
  }

  alarm_actions = [module.monitoring.sns_ops_alerts_arn]
  tags          = local.common_tags

  depends_on = [module.monitoring, module.database]
}
