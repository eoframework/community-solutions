#------------------------------------------------------------------------------
# Amatra Agentic Orchestration Platform — DR Environment
# Region: us-west-2 | Opportunity: OPP-2026-001
# DR mirrors production configuration — PITR enabled, WAF disabled
#------------------------------------------------------------------------------

locals {
  environment = "dr"
  name_prefix = var.project.resource_name_prefix

  common_tags = {
    Solution           = var.project.solution_name
    Environment        = local.environment
    Application        = var.application.name
    ManagedBy          = "terraform"
    CostCenter         = var.project.opportunity_id
    Project            = var.project.solution_name
    DataClassification = "confidential"
    Purpose            = "DisasterRecovery"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#===============================================================================
# FOUNDATION — Identity, secrets, and storage primitives
#===============================================================================

module "cognito" {
  source = "../../modules/aws/cognito"

  name_prefix                 = local.name_prefix
  user_pool_name              = var.security.cognito_user_pool_name
  access_token_validity       = var.security.access_token_expiry_seconds
  refresh_token_validity_days = var.security.refresh_token_expiry_days
  mfa_configuration           = var.security.mfa_enabled ? "OPTIONAL" : "OFF"
  group_consultants           = var.security.group_consultants
  group_admins                = var.security.group_admins
  post_confirmation_lambda_arn = module.lambda.post_confirmation_function_arn
  common_tags                 = local.common_tags

  depends_on = []
}

module "storage" {
  source = "../../modules/aws/s3"

  name_prefix                       = local.name_prefix
  artifacts_bucket_name             = var.storage.artifacts_bucket_name
  guidance_bucket_name              = var.storage.guidance_bucket_name
  cloudtrail_bucket_name            = var.security.cloudtrail_s3_bucket_name
  artifacts_versioning_enabled      = var.storage.artifacts_versioning_enabled
  artifacts_intelligent_tiering_days = var.storage.artifacts_intelligent_tiering_days
  s3_version_retention_days         = var.operations.s3_version_retention_days
  artifacts_prefix_raw              = var.storage.artifacts_prefix_raw
  artifacts_prefix_converted        = var.storage.artifacts_prefix_converted
  terraform_prefix                  = var.storage.terraform_prefix
  common_tags                       = local.common_tags

  depends_on = []
}

module "ecr" {
  source = "../../modules/aws/ecr"

  name_prefix          = local.name_prefix
  repository_name      = var.storage.ecr_repository_name
  image_scan_on_push   = var.storage.ecr_image_scan_on_push
  image_tag_policy     = var.compute.agentcore_image_tag_policy
  common_tags          = local.common_tags

  depends_on = []
}

#===============================================================================
# CORE SOLUTION — DynamoDB, Lambda, API Gateway (DR mirrors prod)
#===============================================================================

module "database" {
  source = "../../modules/aws/dynamodb"

  name_prefix                    = local.name_prefix
  billing_mode                   = var.database.billing_mode
  pitr_enabled                   = var.database.pitr_enabled
  users_table_name               = var.database.users_table_name
  solutions_table_name           = var.database.solutions_table_name
  global_quota_table_name        = var.database.global_quota_table_name
  encryption_key_alias           = var.database.encryption_key_alias
  user_monthly_solution_limit    = var.quota.user_monthly_solution_limit
  global_monthly_solution_limit  = var.quota.global_monthly_solution_limit
  common_tags                    = local.common_tags

  depends_on = [module.storage]
}

module "iam" {
  source = "../../modules/aws/iam"

  name_prefix                           = local.name_prefix
  aws_region                            = var.aws.region
  aws_account_id                        = data.aws_caller_identity.current.account_id
  users_table_name                      = var.database.users_table_name
  solutions_table_name                  = var.database.solutions_table_name
  global_quota_table_name               = var.database.global_quota_table_name
  artifacts_bucket_name                 = var.storage.artifacts_bucket_name
  guidance_bucket_name                  = var.storage.guidance_bucket_name
  artifacts_prefix_raw                  = var.storage.artifacts_prefix_raw
  artifacts_prefix_converted            = var.storage.artifacts_prefix_converted
  terraform_prefix                      = var.storage.terraform_prefix
  github_pat_secret_name                = var.security.github_pat_secret_name
  bedrock_generation_model_id           = var.integration.bedrock_generation_model_id
  bedrock_validation_model_id           = var.integration.bedrock_validation_model_id
  ssm_s3_artifacts_bucket_param         = var.operations.ssm_s3_artifacts_bucket_param
  ssm_dynamodb_solutions_table_param    = var.operations.ssm_dynamodb_solutions_table_param
  common_tags                           = local.common_tags

  depends_on = [module.database, module.storage]
}

module "secrets" {
  source = "../../modules/aws/secrets-manager"

  name_prefix            = local.name_prefix
  github_pat_secret_name = var.security.github_pat_secret_name
  common_tags            = local.common_tags

  depends_on = []
}

module "ssm" {
  source = "../../modules/aws/ssm"

  name_prefix                        = local.name_prefix
  artifacts_bucket_name              = var.storage.artifacts_bucket_name
  solutions_table_name               = var.database.solutions_table_name
  ssm_s3_artifacts_bucket_param      = var.operations.ssm_s3_artifacts_bucket_param
  ssm_dynamodb_solutions_table_param = var.operations.ssm_dynamodb_solutions_table_param
  common_tags                        = local.common_tags

  depends_on = [module.storage, module.database]
}

module "lambda" {
  source = "../../modules/aws/lambda"

  name_prefix    = local.name_prefix
  lambda_runtime = var.compute.lambda_runtime
  aws_region     = var.aws.region

  solution_create_memory_mb               = var.compute.solution_create_memory_mb
  solution_create_timeout_seconds         = var.compute.solution_create_timeout_seconds
  solution_create_concurrency_limit       = var.compute.solution_create_concurrency_limit
  solution_create_provisioned_concurrency = var.compute.solution_create_provisioned_concurrency

  status_memory_mb       = var.compute.status_memory_mb
  status_timeout_seconds = var.compute.status_timeout_seconds

  artifact_fetch_memory_mb       = var.compute.artifact_fetch_memory_mb
  artifact_fetch_timeout_seconds = var.compute.artifact_fetch_timeout_seconds

  admin_usage_memory_mb       = var.compute.admin_usage_memory_mb
  admin_usage_timeout_seconds = var.compute.admin_usage_timeout_seconds

  github_integration_memory_mb         = var.compute.github_integration_memory_mb
  github_integration_timeout_seconds   = var.compute.github_integration_timeout_seconds
  github_integration_concurrency_limit = var.compute.github_integration_concurrency_limit

  post_confirmation_memory_mb       = var.compute.post_confirmation_memory_mb
  post_confirmation_timeout_seconds = var.compute.post_confirmation_timeout_seconds

  xray_tracing_enabled              = var.monitoring.xray_tracing_enabled
  log_retention_days                = var.monitoring.log_retention_days
  log_level                         = var.application.log_level
  application_name                  = var.application.name
  application_version               = var.application.version

  github_pat_secret_name            = var.security.github_pat_secret_name
  github_repository_url             = var.integration.github_repository_url
  github_commit_retry_count         = var.integration.github_commit_retry_count
  github_branch                     = var.integration.github_branch

  bedrock_generation_model_id       = var.integration.bedrock_generation_model_id
  bedrock_validation_model_id       = var.integration.bedrock_validation_model_id
  bedrock_max_retries               = var.integration.bedrock_max_retries_per_artifact
  bedrock_retry_initial_delay_ms    = var.integration.bedrock_generation_retry_initial_delay_ms

  users_table_name              = var.database.users_table_name
  solutions_table_name          = var.database.solutions_table_name
  global_quota_table_name       = var.database.global_quota_table_name
  artifacts_bucket_name         = var.storage.artifacts_bucket_name
  artifacts_prefix_raw          = var.storage.artifacts_prefix_raw
  artifacts_prefix_converted    = var.storage.artifacts_prefix_converted
  terraform_prefix              = var.storage.terraform_prefix

  user_monthly_solution_limit   = var.quota.user_monthly_solution_limit
  global_monthly_solution_limit = var.quota.global_monthly_solution_limit

  ssm_s3_artifacts_bucket_param      = var.operations.ssm_s3_artifacts_bucket_param
  ssm_dynamodb_solutions_table_param = var.operations.ssm_dynamodb_solutions_table_param

  solution_create_role_arn       = module.iam.solution_create_role_arn
  status_role_arn                = module.iam.status_role_arn
  artifact_fetch_role_arn        = module.iam.artifact_fetch_role_arn
  admin_usage_role_arn           = module.iam.admin_usage_role_arn
  github_integration_role_arn    = module.iam.github_integration_role_arn
  post_confirmation_role_arn     = module.iam.post_confirmation_role_arn
  common_tags                    = local.common_tags

  depends_on = [module.database, module.storage, module.iam, module.secrets, module.ssm]
}

module "api_gateway" {
  source = "../../modules/aws/api-gateway"

  name_prefix                   = local.name_prefix
  stage_name                    = var.networking.api_gateway_stage_name
  throttle_burst_limit          = var.networking.api_gateway_throttle_burst_limit
  throttle_rate_limit           = var.networking.api_gateway_throttle_rate_limit
  custom_domain                 = var.networking.api_gateway_custom_domain
  tls_minimum_version           = var.networking.api_gateway_tls_minimum_version
  xray_tracing_enabled          = var.monitoring.xray_tracing_enabled
  log_retention_days            = var.monitoring.log_retention_days

  cognito_user_pool_id          = module.cognito.user_pool_id
  cognito_user_pool_endpoint    = module.cognito.user_pool_endpoint

  solution_create_function_arn  = module.lambda.solution_create_function_arn
  status_function_arn           = module.lambda.status_function_arn
  artifact_fetch_function_arn   = module.lambda.artifact_fetch_function_arn
  admin_usage_function_arn      = module.lambda.admin_usage_function_arn
  common_tags                   = local.common_tags

  depends_on = [module.cognito, module.lambda]
}

#===============================================================================
# OPERATIONS — Monitoring enabled; WAF/CloudTrail managed at prod
#===============================================================================

module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix                        = local.name_prefix
  log_retention_days                 = var.monitoring.log_retention_days
  dashboard_platform_health          = var.monitoring.dashboard_platform_health
  dashboard_throughput               = var.monitoring.dashboard_throughput
  dashboard_cost_telemetry           = var.monitoring.dashboard_cost_telemetry
  dashboard_quota_utilisation        = var.monitoring.dashboard_quota_utilisation
  sns_topic_name                     = var.monitoring.sns_topic_name
  lambda_error_rate_threshold_pct    = var.monitoring.lambda_error_rate_threshold_pct
  bedrock_cost_anomaly_threshold_usd = var.monitoring.bedrock_cost_anomaly_threshold_usd
  canary_endpoint_path               = var.monitoring.canary_endpoint_path
  canary_interval_minutes            = var.monitoring.canary_interval_minutes
  global_alert_threshold_pct         = var.quota.global_alert_threshold_pct
  user_alert_threshold_count         = var.quota.user_alert_threshold_count
  global_monthly_solution_limit      = var.quota.global_monthly_solution_limit
  aws_region                         = var.aws.region
  common_tags                        = local.common_tags

  depends_on = [module.lambda, module.api_gateway]
}

#===============================================================================
# INTEGRATIONS — Cross-module wiring
#===============================================================================

# CloudWatch alarm: Solution Create Lambda error rate (DR availability monitoring)
resource "aws_cloudwatch_metric_alarm" "solution_create_errors" {
  alarm_name          = "${local.name_prefix}-solution-create-error-rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = var.monitoring.lambda_error_rate_threshold_pct
  alarm_description   = "DR: Solution Create Lambda error count exceeds threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = module.lambda.solution_create_function_name
  }

  alarm_actions = [module.monitoring.sns_topic_arn]
  ok_actions    = [module.monitoring.sns_topic_arn]
  tags          = local.common_tags

  depends_on = [module.lambda, module.monitoring]
}

# SSM parameter for API Gateway URL
resource "aws_ssm_parameter" "api_gateway_url" {
  name  = "/${var.application.name}/${local.environment}/api-gateway-url"
  type  = "String"
  value = module.api_gateway.api_endpoint
  tags  = local.common_tags

  depends_on = [module.api_gateway]
}
