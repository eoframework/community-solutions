#------------------------------------------------------------------------------
# ANP Streaming AI - Test Environment
#------------------------------------------------------------------------------

locals {
  environment = "test"
  name_prefix = "${var.solution.name}-${local.environment}"

  common_tags = {
    Solution      = var.solution.name
    Environment   = local.environment
    Project       = var.operations.tagging_project
    CostCenter    = var.operations.tagging_cost_center
    ManagedBy     = "terraform"
    OpportunityId = var.solution.opportunity_id
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#===============================================================================
# FOUNDATION - Security controls, IAM policies, CloudTrail
#===============================================================================
module "security" {
  source = "../../modules/security"

  name_prefix             = local.name_prefix
  environment             = local.environment
  aws_region              = var.aws.region
  cloudtrail_bucket_name  = "${var.solution.name}-cloudtrail-${local.environment}"
  enable_cloudtrail       = var.security.cloudtrail_enabled
  catalog_table_name      = var.database.catalog_table_name
  user_history_table_name = var.database.user_history_table_name
  catalog_bucket_name     = var.storage.catalog_bucket_name
  catalog_prefix          = var.storage.catalog_prefix
  common_tags             = local.common_tags
}

#===============================================================================
# CORE SOLUTION - Storage, Database, Processing, API
#===============================================================================

module "storage" {
  source = "../../modules/storage"

  bucket_name              = var.storage.catalog_bucket_name
  versioning_enabled       = var.storage.versioning_enabled
  catalog_prefix           = var.storage.catalog_prefix
  autotagger_lambda_arn    = ""
  autotagger_function_name = ""
  common_tags              = local.common_tags
  depends_on               = [module.security]
}

module "database" {
  source = "../../modules/database"

  catalog_table_name         = var.database.catalog_table_name
  catalog_gsi_name           = var.database.catalog_gsi_name
  catalog_pitr_enabled       = var.database.catalog_pitr_enabled
  billing_mode               = var.database.billing_mode
  user_history_table_name    = var.database.user_history_table_name
  user_history_ttl_attribute = var.database.user_history_ttl_attribute
  user_history_pitr_enabled  = var.database.user_history_pitr_enabled
  common_tags                = local.common_tags
  depends_on                 = [module.security]
}

module "processing" {
  source = "../../modules/processing"

  environment              = local.environment
  aws_region               = var.aws.region
  log_level                = var.application.log_level
  lambda_runtime           = var.compute.lambda_runtime
  enable_xray              = var.monitoring.xray_enabled
  log_retention_days       = var.monitoring.log_retention_days
  mood_labels              = var.application.mood_labels
  bedrock_max_tokens       = var.compute.bedrock_max_tokens
  min_confidence_threshold = tostring(var.database.min_confidence_threshold)

  classifier_function_name   = var.compute.classifier_function_name
  classifier_memory_mb       = var.compute.classifier_memory_mb
  classifier_timeout_seconds = var.compute.classifier_timeout_seconds
  classifier_policy_arn      = module.security.classifier_policy_arn

  recommender_function_name   = var.compute.recommender_function_name
  recommender_memory_mb       = var.compute.recommender_memory_mb
  recommender_timeout_seconds = var.compute.recommender_timeout_seconds
  recommender_policy_arn      = module.security.recommender_policy_arn

  catalog_table_name      = module.database.catalog_table_name
  user_history_table_name = module.database.user_history_table_name
  catalog_gsi_name        = var.database.catalog_gsi_name
  history_lookback        = var.compute.history_lookback
  recommend_default_limit = var.application.recommend_default_limit
  recommend_max_limit     = var.application.recommend_max_limit

  autotagger_function_name   = var.compute.autotagger_function_name
  autotagger_dlq_name        = var.compute.autotagger_dlq_name
  autotagger_memory_mb       = var.compute.autotagger_memory_mb
  autotagger_timeout_seconds = var.compute.autotagger_timeout_seconds
  autotagger_max_retries     = var.compute.autotagger_max_retries
  autotagger_policy_arn      = module.security.autotagger_policy_arn

  common_tags = local.common_tags
  depends_on  = [module.security, module.database]
}

module "api" {
  source = "../../modules/api"

  api_name              = var.compute.apigw_api_name
  stage_name            = var.application.api_stage
  rate_limit_rps        = var.compute.apigw_rate_limit_rps
  burst_limit           = var.compute.apigw_burst_limit
  classifier_function_name  = module.processing.classifier_function_name
  classifier_invoke_arn     = module.processing.classifier_invoke_arn
  recommender_function_name = module.processing.recommender_function_name
  recommender_invoke_arn    = module.processing.recommender_invoke_arn
  cognito_user_pool_arn = var.integration.cognito_user_pool_arn
  enable_xray           = var.monitoring.xray_enabled
  log_retention_days    = var.monitoring.log_retention_days
  common_tags           = local.common_tags
  depends_on            = [module.processing]
}

#===============================================================================
# OPERATIONS - Monitoring, Dashboards, Alarms
#===============================================================================
module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix               = local.name_prefix
  classifier_function_name  = module.processing.classifier_function_name
  recommender_function_name = module.processing.recommender_function_name
  autotagger_function_name  = module.processing.autotagger_function_name
  autotagger_dlq_name       = module.processing.autotagger_dlq_name
  api_name                  = var.compute.apigw_api_name
  api_stage                 = var.application.api_stage
  catalog_table_name        = module.database.catalog_table_name

  lambda_error_threshold         = var.monitoring.lambda_error_threshold
  apigw_p95_latency_threshold_ms = var.monitoring.apigw_p95_latency_ms
  apigw_5xx_threshold            = var.monitoring.apigw_5xx_count
  dlq_depth_threshold            = var.monitoring.autotagger_dlq_depth
  dynamodb_throttle_threshold    = var.monitoring.dynamodb_throttle_count
  operations_dashboard_name      = var.monitoring.dashboard_operations
  cost_dashboard_name            = var.monitoring.dashboard_cost
  common_tags                    = local.common_tags
  depends_on                     = [module.processing, module.api]
}

#===============================================================================
# INTEGRATIONS - Cross-module wiring (avoids circular dependencies)
#===============================================================================

resource "aws_s3_bucket_notification" "autotagger_trigger" {
  bucket = module.storage.bucket_id

  lambda_function {
    lambda_function_arn = module.processing.autotagger_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.storage.catalog_prefix
  }

  depends_on = [module.storage, module.processing]
}

resource "aws_lambda_permission" "s3_autotagger" {
  statement_id  = "AllowS3InvokeAutoTagger"
  action        = "lambda:InvokeFunction"
  function_name = module.processing.autotagger_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.storage.bucket_arn
  depends_on    = [module.storage, module.processing]
}
