#------------------------------------------------------------------------------
# Amatra Intelligent Solution Builder — Test Environment
# Minimal footprint for feature development and integration testing
# Region: us-west-2 | Note: WAF/GuardDuty disabled to reduce cost
#------------------------------------------------------------------------------

locals {
  environment = "test"
  name_prefix = "${var.solution.abbr}-${local.environment}"
  api_name    = "${local.name_prefix}-api"

  project = {
    name        = var.solution.abbr
    environment = local.environment
  }

  common_tags = {
    Solution         = var.solution.name
    SolutionAbbr     = var.solution.abbr
    Environment      = local.environment
    Provider         = var.solution.provider_name
    Category         = var.solution.category_name
    Region           = var.aws.region
    ManagedBy        = "terraform"
    CostCenter       = var.ownership.cost_center
    Owner            = var.ownership.owner_email
    ProjectCode      = var.ownership.project_code
    Phase            = var.ownership.phase
    Compliance       = var.ownership.compliance
    DataClassification = "internal"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#===============================================================================
# FOUNDATION — Encryption keys (WAF/GuardDuty disabled in test)
#===============================================================================
module "kms" {
  source = "../../modules/aws/kms"

  name_prefix    = local.name_prefix
  environment    = local.environment
  common_tags    = local.common_tags
  enable_s3_key          = true
  enable_dynamodb_key    = true
  enable_cloudtrail_key  = false
  enable_secrets_key     = true
  s3_key_alias           = var.database.encryption_key_alias
  dynamodb_key_alias     = var.database.encryption_key_alias
  cloudtrail_key_alias   = "alias/${local.name_prefix}-cloudtrail"
  secrets_key_alias      = "alias/${local.name_prefix}-secrets"
}

module "security" {
  source = "../../modules/security"

  name_prefix             = local.name_prefix
  environment             = local.environment
  common_tags             = local.common_tags
  kms_s3_key_arn          = module.kms.s3_key_arn
  kms_secrets_key_arn     = module.kms.secrets_key_arn
  cognito                 = var.security.cognito
  waf_rate_limit          = var.security.waf.rate_limit_per_ip_per_5min
  enable_waf              = false
  enable_guardduty        = var.security.guardduty_enabled
  enable_securityhub      = var.security.securityhub_enabled
  s3_block_public_access  = var.security.s3_block_public_access
  session_timeout_minutes = var.security.session_timeout_minutes

  depends_on = [module.kms]
}

#===============================================================================
# CORE SOLUTION — Storage, messaging, compute, and orchestration
#===============================================================================
module "storage" {
  source = "../../modules/storage"

  name_prefix                       = local.name_prefix
  environment                       = local.environment
  common_tags                       = local.common_tags
  kms_s3_key_arn                    = module.kms.s3_key_arn
  artifacts_bucket_name             = var.storage.artifacts_bucket_name
  cloudtrail_bucket_name            = var.storage.cloudtrail_bucket_name
  templates_bucket_name             = var.storage.templates_bucket_name
  artifacts_lifecycle_standard_days = var.storage.artifacts_lifecycle_standard_days
  versioning_enabled                = var.storage.versioning_enabled
  cloudtrail_retention_years        = var.security.cloudtrail_retention_years

  depends_on = [module.kms]
}

module "database" {
  source = "../../modules/database"

  name_prefix               = local.name_prefix
  environment               = local.environment
  common_tags               = local.common_tags
  kms_dynamodb_key_arn      = module.kms.dynamodb_key_arn
  solution_state_table_name = var.database.solution_state_table
  usage_tracking_table_name = var.database.usage_tracking_table
  billing_mode              = var.database.billing_mode
  pitr_enabled              = var.database.pitr_enabled
  ttl_solution_state_days   = var.database.ttl_solution_state_days
  ttl_usage_tracking_days   = var.database.ttl_usage_tracking_days

  depends_on = [module.kms]
}

module "messaging" {
  source = "../../modules/messaging"

  name_prefix                = local.name_prefix
  environment                = local.environment
  common_tags                = local.common_tags
  kms_key_arn                = module.kms.s3_key_arn
  job_queue_name             = var.integration.sqs.job_queue_name
  dlq_name                   = var.integration.sqs.dlq_name
  visibility_timeout_seconds = var.integration.sqs.visibility_timeout_seconds
  message_retention_seconds  = var.integration.sqs.message_retention_seconds
  max_receive_count          = var.integration.sqs.max_receive_count

  depends_on = [module.kms]
}

module "api" {
  source = "../../modules/api"

  name_prefix              = local.name_prefix
  environment              = local.environment
  common_tags              = local.common_tags
  api_name                 = local.api_name
  api_version              = var.application.api_version
  stage_name               = var.integration.api_gateway.stage_name
  throttle_burst_rps       = var.integration.api_gateway.throttle_burst_rps
  throttle_steady_rps      = var.integration.api_gateway.throttle_steady_rps
  cognito_user_pool_arn    = module.security.cognito_user_pool_arn
  log_retention_days       = var.monitoring.cloudwatch.log_retention_days

  depends_on = [module.security]
}

module "compute" {
  source = "../../modules/compute"

  name_prefix                    = local.name_prefix
  environment                    = local.environment
  common_tags                    = local.common_tags
  aws_region                     = var.aws.region
  runtime                        = var.compute.runtime
  lambda_alias                   = var.compute.lambda_alias
  log_retention_days             = var.monitoring.cloudwatch.log_retention_days
  log_level                      = var.application.log_level
  secret_prefix                  = var.integration.secrets_manager.secret_prefix
  kms_key_arn                    = module.kms.secrets_key_arn
  artifacts_bucket_name          = var.storage.artifacts_bucket_name
  templates_bucket_name          = var.storage.templates_bucket_name
  solution_state_table_name      = var.database.solution_state_table
  usage_tracking_table_name      = var.database.usage_tracking_table
  job_queue_arn                  = module.messaging.job_queue_arn
  job_queue_url                  = module.messaging.job_queue_url
  state_machine_name             = "${local.name_prefix}-generation-workflow"
  sonnet_model_id                = var.integration.bedrock.sonnet_model_id
  haiku_model_id                 = var.integration.bedrock.haiku_model_id
  api_submit_memory              = var.compute.api_submit.memory_mb
  api_submit_timeout             = var.compute.api_submit.timeout_seconds
  api_submit_provisioned         = var.compute.api_submit.provisioned_concurrency
  api_status_memory              = var.compute.api_status.memory_mb
  api_status_timeout             = var.compute.api_status.timeout_seconds
  api_status_provisioned         = var.compute.api_status.provisioned_concurrency
  api_retrieve_memory            = var.compute.api_retrieve.memory_mb
  api_retrieve_timeout           = var.compute.api_retrieve.timeout_seconds
  api_retrieve_provisioned       = var.compute.api_retrieve.provisioned_concurrency
  api_admin_memory               = var.compute.api_admin.memory_mb
  api_admin_timeout              = var.compute.api_admin.timeout_seconds
  api_admin_provisioned          = var.compute.api_admin.provisioned_concurrency
  orchestrator_memory            = var.compute.orchestrator_start.memory_mb
  orchestrator_timeout           = var.compute.orchestrator_start.timeout_seconds
  bedrock_sonnet_memory          = var.compute.bedrock_sonnet.memory_mb
  bedrock_sonnet_timeout         = var.compute.bedrock_sonnet.timeout_seconds
  bedrock_haiku_memory           = var.compute.bedrock_haiku.memory_mb
  bedrock_haiku_timeout          = var.compute.bedrock_haiku.timeout_seconds
  artifact_processor_memory      = var.compute.artifact_processor.memory_mb
  artifact_processor_timeout     = var.compute.artifact_processor.timeout_seconds
  reserved_concurrency_total     = var.compute.reserved_concurrency_total
  presigned_url_ttl_seconds      = var.application.presigned_url_ttl_seconds
  per_user_monthly_limit         = var.operations.usage_limit.per_user_monthly_default
  global_monthly_limit           = var.operations.usage_limit.global_monthly_default

  depends_on = [module.kms, module.storage, module.database, module.messaging]
}

module "orchestration" {
  source = "../../modules/orchestration"

  name_prefix                = local.name_prefix
  environment                = local.environment
  common_tags                = local.common_tags
  state_machine_name         = "${local.name_prefix}-generation-workflow"
  sonnet_invoker_arn         = module.compute.bedrock_sonnet_lambda_arn
  haiku_invoker_arn          = module.compute.bedrock_haiku_lambda_arn
  artifact_processor_arn     = module.compute.artifact_processor_lambda_arn
  prompt_assembly_arn        = module.compute.orchestrator_start_lambda_arn
  solution_state_table_name  = var.database.solution_state_table
  kms_key_arn                = module.kms.secrets_key_arn
  retry_max_attempts         = var.integration.bedrock.retry_max_attempts
  retry_interval_seconds     = var.integration.bedrock.retry_interval_seconds
  log_retention_days         = var.monitoring.cloudwatch.log_retention_days

  depends_on = [module.compute, module.database]
}

#===============================================================================
# OPERATIONS — Monitoring and alerting (reduced scope for test)
#===============================================================================
module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix                    = local.name_prefix
  environment                    = local.environment
  common_tags                    = local.common_tags
  aws_region                     = var.aws.region
  operations_dashboard_name      = var.monitoring.cloudwatch.operations_dashboard
  sla_dashboard_name             = var.monitoring.cloudwatch.sla_dashboard
  quality_dashboard_name         = var.monitoring.cloudwatch.quality_dashboard
  log_retention_days             = var.monitoring.cloudwatch.log_retention_days
  job_failure_rate_threshold_pct = var.monitoring.alarm.job_failure_rate_threshold_pct
  api_5xx_threshold_pct          = var.monitoring.alarm.api_5xx_threshold_pct
  bedrock_budget_warning_pct     = var.monitoring.alarm.bedrock_budget_warning_pct
  dlq_depth_threshold            = var.monitoring.alarm.dlq_depth_threshold
  cognito_auth_failure_pct       = var.monitoring.alarm.cognito_auth_failure_pct
  health_check_interval_seconds  = var.monitoring.synthetics.health_check_interval_seconds
  api_version                    = var.application.api_version
  rest_api_id                    = module.api.rest_api_id
  api_stage_name                 = var.integration.api_gateway.stage_name
  dlq_name                       = var.integration.sqs.dlq_name
  state_machine_arn              = module.orchestration.state_machine_arn
  cognito_user_pool_id           = module.security.cognito_user_pool_id
  bedrock_max_input_tokens       = var.integration.bedrock.max_input_tokens_monthly
  bedrock_max_output_tokens      = var.integration.bedrock.max_output_tokens_monthly

  depends_on = [module.api, module.compute, module.messaging, module.orchestration, module.security]
}

module "best_practices" {
  source = "../../modules/best-practices"

  name_prefix               = local.name_prefix
  environment               = local.environment
  common_tags               = local.common_tags
  enable_cloudtrail         = var.security.cloudtrail_enabled
  cloudtrail_bucket_name    = var.storage.cloudtrail_bucket_name
  cloudtrail_kms_key_arn    = module.kms.cloudtrail_key_arn
  enable_config_rules       = false
  sns_topic_arn             = module.monitoring.sns_topic_arn
  cognito_export_schedule   = var.operations.backup.cognito_export_schedule
  artifacts_bucket_name     = var.storage.artifacts_bucket_name
  kms_key_arn               = module.kms.s3_key_arn
  cognito_user_pool_id      = module.security.cognito_user_pool_id

  depends_on = [module.kms, module.storage, module.monitoring, module.security]
}

#===============================================================================
# INTEGRATIONS — Cross-module wiring (avoids circular dependencies)
#===============================================================================

# Lambda → API Gateway integration (submit)
resource "aws_lambda_permission" "api_submit" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.compute.api_submit_lambda_name
  qualifier     = var.compute.lambda_alias
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api.execution_arn}/*/*"

  depends_on = [module.compute, module.api]
}

# Lambda → API Gateway integration (status)
resource "aws_lambda_permission" "api_status" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.compute.api_status_lambda_name
  qualifier     = var.compute.lambda_alias
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api.execution_arn}/*/*"

  depends_on = [module.compute, module.api]
}

# Lambda → API Gateway integration (retrieve)
resource "aws_lambda_permission" "api_retrieve" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.compute.api_retrieve_lambda_name
  qualifier     = var.compute.lambda_alias
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api.execution_arn}/*/*"

  depends_on = [module.compute, module.api]
}

# Lambda → API Gateway integration (admin)
resource "aws_lambda_permission" "api_admin" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.compute.api_admin_lambda_name
  qualifier     = var.compute.lambda_alias
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api.execution_arn}/*/*"

  depends_on = [module.compute, module.api]
}

# SQS → Orchestrator Lambda trigger
resource "aws_lambda_event_source_mapping" "sqs_to_orchestrator" {
  event_source_arn = module.messaging.job_queue_arn
  function_name    = module.compute.orchestrator_start_lambda_arn
  batch_size       = 1
  enabled          = true

  depends_on = [module.compute, module.messaging]
}

# DLQ depth alarm → SNS
resource "aws_cloudwatch_metric_alarm" "dlq_depth" {
  alarm_name          = "${local.name_prefix}-dlq-depth-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = var.monitoring.alarm.dlq_depth_threshold
  alarm_description   = "DLQ message received — generation job failed after max retries"
  alarm_actions       = [module.monitoring.sns_topic_arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    QueueName = var.integration.sqs.dlq_name
  }
  tags = local.common_tags

  depends_on = [module.monitoring, module.messaging]
}
