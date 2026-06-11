###############################################################################
# Amatra Intelligent Solution Builder — Test Environment
# Cost-optimised: 1 NAT GW, no WAF, minimal concurrency, PITR disabled.
###############################################################################

locals {
  environment   = "test"
  name_prefix   = "amatra-${local.environment}"
  solution_abbr = "aisb"

  common_tags = {
    Solution        = var.project.solution_name
    SolutionAbbr    = local.solution_abbr
    Environment     = local.environment
    Application     = var.application.name
    ManagedBy       = "terraform"
    CostCenter      = var.project.cost_center
    DataClassification = "Internal"
    DataResidency   = "us-west-2"
  }

  availability_zones = [
    "${var.project.region}a",
    "${var.project.region}b",
    "${var.project.region}c"
  ]
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#===============================================================================
# FOUNDATION
#===============================================================================
module "security" {
  source      = "../../modules/security"
  name_prefix = local.name_prefix
  enable_waf  = var.security.enable_waf
  waf_rate_limit_per_5_min = var.security.waf_rate_limit_per_5_min
  log_retention_days       = var.monitoring.log_retention_days
  common_tags              = local.common_tags
}

module "networking" {
  source      = "../../modules/networking"
  name_prefix = local.name_prefix
  region      = var.project.region

  vpc_cidr             = var.network.vpc_cidr
  public_subnet_cidrs  = var.network.public_subnet_cidrs
  private_subnet_cidrs = var.network.private_subnet_cidrs
  availability_zones   = local.availability_zones
  nat_gateway_count    = var.network.nat_gateway_count
  enable_privatelink_endpoints = var.network.enable_privatelink_endpoints

  common_tags = local.common_tags
  depends_on  = [module.security]
}

#===============================================================================
# CORE SOLUTION
#===============================================================================
module "storage" {
  source = "../../modules/storage"

  artifacts_bucket_name       = var.storage.artifacts_bucket_name
  terraform_state_bucket_name = var.storage.terraform_state_bucket
  solution_state_table_name   = var.storage.solution_state_table
  usage_tracking_table_name   = var.storage.usage_tracking_table
  audit_table_name            = var.storage.audit_table
  terraform_lock_table_name   = var.storage.terraform_lock_table

  kms_artifacts_key_arn = module.security.kms_artifacts_key_arn
  kms_database_key_arn  = module.security.kms_database_key_arn

  s3_versioning_enabled      = var.storage.s3_versioning_enabled
  s3_intelligent_tiering_days = var.storage.s3_intelligent_tiering_days
  s3_glacier_transition_days  = var.storage.s3_glacier_transition_days
  pitr_enabled               = var.storage.pitr_enabled
  deletion_protection_enabled = false

  enable_s3_replication      = false
  s3_replication_role_arn    = ""
  dr_replication_bucket_arn  = ""
  dr_replication_kms_key_arn = ""
  force_destroy              = true

  common_tags = local.common_tags
  depends_on  = [module.security]
}

module "identity" {
  source = "../../modules/identity"

  user_pool_name              = "amatra-users-${local.environment}"
  user_pool_domain            = var.security.cognito_user_pool_domain
  access_token_validity_hours = var.security.cognito_access_token_expiry_hours
  callback_urls               = var.security.cognito_callback_urls
  logout_urls                 = var.security.cognito_logout_urls
  user_groups                 = var.security.cognito_user_groups

  common_tags = local.common_tags
  depends_on  = [module.security]
}

module "compute" {
  source = "../../modules/compute"

  name_prefix  = local.name_prefix
  environment  = local.environment
  log_level    = var.application.log_level
  app_version  = var.application.version
  log_retention_days = var.monitoring.log_retention_days

  generation_queue_name         = var.integration.sqs_generation_queue_name
  dlq_name                      = var.integration.sqs_dlq_name
  sqs_message_retention_seconds = var.integration.sqs_message_retention_seconds
  sqs_max_receive_count         = var.integration.sqs_max_receive_count

  workflow_name              = var.compute.stepfunctions_workflow_name
  sfn_max_retry_attempts     = var.compute.stepfunctions_max_retry_attempts
  sfn_retry_backoff_rate     = var.compute.stepfunctions_retry_backoff_rate
  sfn_retry_interval_seconds = var.compute.stepfunctions_retry_interval_seconds

  ecr_repository_prefix    = var.compute.ecr_repository_prefix
  ecr_image_tag_mutability = var.compute.ecr_image_tag_mutability

  private_subnet_ids       = module.networking.private_subnet_ids
  lambda_security_group_id = module.networking.lambda_security_group_id

  kms_artifacts_key_arn = module.security.kms_artifacts_key_arn
  kms_database_key_arn  = module.security.kms_database_key_arn
  kms_audit_key_arn     = module.security.kms_audit_key_arn

  solution_state_table_name = module.storage.solution_state_table_name
  solution_state_table_arn  = module.storage.solution_state_table_arn
  usage_tracking_table_name = module.storage.usage_tracking_table_name
  usage_tracking_table_arn  = module.storage.usage_tracking_table_arn
  audit_table_name          = module.storage.audit_table_name
  audit_table_arn           = module.storage.audit_table_arn
  artifacts_bucket_name     = module.storage.artifacts_bucket_id
  artifacts_bucket_arn      = module.storage.artifacts_bucket_arn

  bedrock_model_id                = var.ai.bedrock_model_id
  bedrock_region                  = var.ai.bedrock_region
  bedrock_max_tokens_per_artifact = var.ai.max_tokens_per_artifact
  presigned_url_expiry_seconds    = var.application.presigned_url_expiry_seconds
  force_destroy                   = true

  compute = {
    architecture                            = var.compute.lambda_architecture
    brief_submission_memory_mb              = var.compute.brief_submission_memory_mb
    brief_submission_timeout_seconds        = var.compute.brief_submission_timeout_seconds
    brief_submission_reserved_concurrency   = var.compute.brief_submission_reserved_concurrency
    brief_submission_provisioned_concurrency = var.compute.brief_submission_provisioned_concurrency
    job_status_memory_mb                    = var.compute.job_status_memory_mb
    job_status_timeout_seconds              = var.compute.job_status_timeout_seconds
    job_status_reserved_concurrency         = var.compute.job_status_reserved_concurrency
    job_status_provisioned_concurrency      = var.compute.job_status_provisioned_concurrency
    artifact_retrieval_memory_mb            = var.compute.artifact_retrieval_memory_mb
    artifact_retrieval_timeout_seconds      = var.compute.artifact_retrieval_timeout_seconds
    artifact_retrieval_reserved_concurrency = var.compute.artifact_retrieval_reserved_concurrency
    admin_governance_memory_mb              = var.compute.admin_governance_memory_mb
    admin_governance_timeout_seconds        = var.compute.admin_governance_timeout_seconds
    admin_governance_reserved_concurrency   = var.compute.admin_governance_reserved_concurrency
    bedrock_orchestration_memory_mb         = var.compute.bedrock_orchestration_memory_mb
    bedrock_orchestration_timeout_seconds   = var.compute.bedrock_orchestration_timeout_seconds
    bedrock_orchestration_reserved_concurrency = var.compute.bedrock_orchestration_reserved_concurrency
    output_validation_memory_mb             = var.compute.output_validation_memory_mb
    output_validation_timeout_seconds       = var.compute.output_validation_timeout_seconds
    output_validation_reserved_concurrency  = var.compute.output_validation_reserved_concurrency
    artifact_template_memory_mb             = var.compute.artifact_template_memory_mb
    artifact_template_timeout_seconds       = var.compute.artifact_template_timeout_seconds
    artifact_template_reserved_concurrency  = var.compute.artifact_template_reserved_concurrency
    ses_notification_memory_mb              = var.compute.ses_notification_memory_mb
    ses_notification_timeout_seconds        = var.compute.ses_notification_timeout_seconds
    health_check_memory_mb                  = var.compute.health_check_memory_mb
  }

  common_tags = local.common_tags
  depends_on  = [module.networking, module.storage, module.security]
}

module "api" {
  source = "../../modules/api"

  api_name              = "amatra-platform-api-${local.environment}"
  environment           = local.environment
  cognito_user_pool_arn = module.identity.user_pool_arn
  kms_audit_key_arn     = module.security.kms_audit_key_arn
  log_retention_days    = var.monitoring.log_retention_days

  common_tags = local.common_tags
  depends_on  = [module.identity, module.security]
}

#===============================================================================
# OPERATIONS
#===============================================================================
module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix    = local.name_prefix
  dashboard_name = var.monitoring.cloudwatch_dashboard_name
  trail_name     = "amatra-platform-trail-${local.environment}"
  cloudtrail_bucket_name = var.storage.cloudtrail_bucket

  kms_audit_key_arn              = module.security.kms_audit_key_arn
  cloudtrail_include_data_events = var.security.cloudtrail_include_data_events

  api_name              = "amatra-platform-api-${local.environment}"
  step_functions_arn    = module.compute.step_functions_arn
  generation_queue_name = var.integration.sqs_generation_queue_name
  dlq_name              = var.integration.sqs_dlq_name

  api_error_rate_threshold_pct = var.monitoring.api_error_rate_threshold_pct
  dlq_message_threshold        = var.monitoring.dlq_message_threshold
  sfn_failure_threshold        = var.monitoring.sfn_failure_threshold
  api_latency_p95_threshold_ms = var.monitoring.api_latency_p95_threshold_ms
  force_destroy                = true

  common_tags = local.common_tags
  depends_on  = [module.compute, module.security, module.storage]
}

#===============================================================================
# INTEGRATIONS
#===============================================================================

# WAF association with API Gateway (WAF disabled in test — controlled by variable)
resource "aws_wafv2_web_acl_association" "api_gateway" {
  count        = var.security.enable_waf ? 1 : 0
  resource_arn = "arn:aws:apigateway:${var.project.region}::/restapis/${module.api.rest_api_id}/stages/${local.environment}"
  web_acl_arn  = module.security.waf_web_acl_arn

  depends_on = [module.api, module.security]
}
