#------------------------------------------------------------------------------
# ANP Streaming AI Recommendation Engine — Production Environment
#------------------------------------------------------------------------------

locals {
  environment = "prod"
  name_prefix = "${var.project.solution_name}-${local.environment}"

  common_tags = {
    Solution     = var.project.solution_name
    Application  = var.project.application_name
    Environment  = local.environment
    CostCenter   = var.project.cost_center
    OpportunityNo = var.project.opportunity_no
    ManagedBy    = "terraform"
  }

  project = {
    name        = var.project.solution_name
    environment = local.environment
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#===============================================================================
# FOUNDATION — Core networking and encryption key infrastructure
#===============================================================================

module "networking" {
  source = "../../modules/aws/vpc"

  name_prefix             = local.name_prefix
  vpc_cidr                = var.networking.vpc_cidr
  public_subnet_az1       = var.networking.public_subnet_az1
  public_subnet_az2       = var.networking.public_subnet_az2
  private_subnet_app_az1  = var.networking.private_subnet_app_az1
  private_subnet_app_az2  = var.networking.private_subnet_app_az2
  private_subnet_data_az1 = var.networking.private_subnet_data_az1
  private_subnet_data_az2 = var.networking.private_subnet_data_az2
  nat_gateway_count       = var.networking.nat_gateway_count
  vpc_gateway_endpoints   = var.networking.vpc_gateway_endpoints
  common_tags             = local.common_tags
}

module "security" {
  source = "../../modules/security"

  name_prefix                       = local.name_prefix
  environment                       = local.environment
  kms_catalog_cmk_alias             = var.security.kms_catalog_cmk_alias
  kms_user_data_cmk_alias           = var.security.kms_user_data_cmk_alias
  kms_model_artifacts_cmk_alias     = var.security.kms_model_artifacts_cmk_alias
  kms_rotation_enabled              = var.security.kms_rotation_enabled
  waf_enabled                       = var.security.waf_enabled
  guardduty_enabled                 = var.security.guardduty_enabled
  cloudtrail_enabled                = var.security.cloudtrail_enabled
  iam_access_analyzer_enabled       = var.security.iam_access_analyzer_enabled
  cognito_token_expiry_minutes      = var.security.cognito_token_expiry_minutes
  cognito_mfa_enabled               = var.security.cognito_mfa_enabled
  log_retention_days                = var.security.log_retention_days
  vpc_id                            = module.networking.vpc_id
  private_subnet_app_ids            = module.networking.private_subnet_app_ids
  common_tags                       = local.common_tags

  depends_on = [module.networking]
}

#===============================================================================
# CORE SOLUTION — Storage, Data, ML, Messaging, and API components
#===============================================================================

module "storage" {
  source = "../../modules/storage"

  name_prefix            = local.name_prefix
  raw_catalog_bucket     = var.storage.raw_catalog_bucket
  transcripts_bucket     = var.storage.transcripts_bucket
  features_bucket        = var.storage.features_bucket
  models_bucket          = var.storage.models_bucket
  cloudtrail_bucket      = var.storage.cloudtrail_bucket
  lifecycle_ia_days      = var.storage.lifecycle_ia_days
  lifecycle_glacier_days = var.storage.lifecycle_glacier_days
  versioning_enabled     = var.storage.versioning_enabled
  catalog_kms_key_arn    = module.security.catalog_kms_key_arn
  model_kms_key_arn      = module.security.model_kms_key_arn
  common_tags            = local.common_tags

  depends_on = [module.security]
}

module "database" {
  source = "../../modules/database"

  name_prefix                = local.name_prefix
  content_catalog_table      = var.database.content_catalog_table
  user_profile_table         = var.database.user_profile_table
  interaction_events_table   = var.database.interaction_events_table
  mood_taxonomy_table        = var.database.mood_taxonomy_table
  billing_mode               = var.database.billing_mode
  pitr_enabled               = var.database.pitr_enabled
  interaction_retention_days = var.database.interaction_retention_days
  user_data_kms_key_arn      = module.security.user_data_kms_key_arn
  catalog_kms_key_arn        = module.security.catalog_kms_key_arn
  common_tags                = local.common_tags

  depends_on = [module.security]
}

module "cache" {
  source = "../../modules/cache"
  count  = var.cache.enabled ? 1 : 0

  name_prefix             = local.name_prefix
  node_type               = var.compute.elasticache_node_type
  playlist_ttl_seconds    = var.cache.playlist_ttl_seconds
  session_ttl_seconds     = var.cache.session_ttl_seconds
  port                    = var.cache.port
  subnet_ids              = module.networking.private_subnet_data_ids
  vpc_id                  = module.networking.vpc_id
  app_security_group_id   = module.security.app_security_group_id
  user_data_kms_key_arn   = module.security.user_data_kms_key_arn
  common_tags             = local.common_tags

  depends_on = [module.networking, module.security]
}

module "messaging" {
  source = "../../modules/messaging"

  name_prefix                          = local.name_prefix
  eventbridge_catalog_bus_name         = var.integration.eventbridge_catalog_bus_name
  sqs_feedback_queue_retention_seconds = var.integration.sqs_feedback_queue_retention_seconds
  sqs_max_receive_count                = var.integration.sqs_max_receive_count
  user_data_kms_key_arn                = module.security.user_data_kms_key_arn
  common_tags                          = local.common_tags

  depends_on = [module.security]
}

module "ml_pipeline" {
  source = "../../modules/ml-pipeline"

  name_prefix                        = local.name_prefix
  environment                        = local.environment
  sagemaker_nlp_endpoint_name        = var.compute.sagemaker_nlp_endpoint_name
  sagemaker_nlp_instance_type        = var.compute.sagemaker_nlp_instance_type
  sagemaker_audio_endpoint_name      = var.compute.sagemaker_audio_endpoint_name
  sagemaker_audio_instance_type      = var.compute.sagemaker_audio_instance_type
  sagemaker_training_instance_type   = var.compute.sagemaker_training_instance_type
  sagemaker_training_use_spot        = var.compute.sagemaker_training_use_spot
  sagemaker_min_instances            = var.compute.sagemaker_min_instances
  sagemaker_model_registry_name      = var.ml.sagemaker_model_registry_name
  sagemaker_max_versions_retained    = var.ml.sagemaker_max_versions_retained
  retraining_schedule_expression     = var.ml.retraining_schedule_expression
  confidence_threshold               = var.ml.classifier_confidence_threshold
  conditional_promotion              = var.ml.retraining_conditional_promotion
  models_bucket_name                 = var.storage.models_bucket
  features_bucket_name               = var.storage.features_bucket
  model_kms_key_arn                  = module.security.model_kms_key_arn
  vpc_id                             = module.networking.vpc_id
  private_subnet_app_ids             = module.networking.private_subnet_app_ids
  app_security_group_id              = module.security.app_security_group_id
  common_tags                        = local.common_tags

  depends_on = [module.networking, module.security, module.storage]
}

module "opensearch" {
  source = "../../modules/aws/opensearch"

  name_prefix           = local.name_prefix
  instance_type         = var.compute.opensearch_instance_type
  volume_gb             = var.compute.opensearch_volume_gb
  subnet_id             = module.networking.private_subnet_data_az1_id
  vpc_id                = module.networking.vpc_id
  app_security_group_id = module.security.app_security_group_id
  catalog_kms_key_arn   = module.security.catalog_kms_key_arn
  common_tags           = local.common_tags

  depends_on = [module.networking, module.security]
}

module "api_service" {
  source = "../../modules/api-service"

  name_prefix                        = local.name_prefix
  environment                        = local.environment
  api_version                        = var.application.api_version
  apigw_stage_name                   = var.compute.apigw_stage_name
  apigw_integration_timeout_ms       = var.compute.apigw_integration_timeout_ms
  apigw_rate_limit_rps               = var.compute.apigw_rate_limit_rps
  lambda_architecture                = var.compute.lambda_architecture
  lambda_playlist_memory_mb          = var.compute.lambda_playlist_memory_mb
  lambda_playlist_timeout_seconds    = var.compute.lambda_playlist_timeout_seconds
  lambda_enrichment_memory_mb        = var.compute.lambda_enrichment_memory_mb
  lambda_enrichment_timeout_seconds  = var.compute.lambda_enrichment_timeout_seconds
  lambda_authorizer_memory_mb        = var.compute.lambda_authorizer_memory_mb
  lambda_authorizer_timeout_seconds  = var.compute.lambda_authorizer_timeout_seconds
  lambda_feedback_memory_mb          = var.compute.lambda_feedback_memory_mb
  lambda_preference_update_memory_mb = var.compute.lambda_preference_update_memory_mb
  lambda_max_concurrency             = var.compute.lambda_max_concurrency
  log_level                          = var.application.log_level
  playlist_count_default             = var.application.playlist_count_default
  cold_start_threshold               = var.application.cold_start_threshold
  xray_tracing_enabled               = var.monitoring.xray_tracing_enabled
  log_retention_days                 = var.monitoring.log_retention_days
  firebase_api_url                   = var.integration.firebase_api_url
  firebase_timeout_ms                = var.integration.firebase_timeout_ms
  bedrock_model_id                   = var.integration.bedrock_model_id
  bedrock_max_tokens                 = var.integration.bedrock_max_tokens
  cognito_user_pool_id_param         = module.security.cognito_user_pool_id_ssm_param
  catalog_kms_key_arn                = module.security.catalog_kms_key_arn
  user_data_kms_key_arn              = module.security.user_data_kms_key_arn
  content_catalog_table_name         = var.database.content_catalog_table
  user_profile_table_name            = var.database.user_profile_table
  interaction_events_table_name      = var.database.interaction_events_table
  mood_taxonomy_table_name           = var.database.mood_taxonomy_table
  feedback_queue_arn                 = module.messaging.feedback_queue_arn
  feedback_queue_url                 = module.messaging.feedback_queue_url
  catalog_event_bus_name             = var.integration.eventbridge_catalog_bus_name
  vpc_id                             = module.networking.vpc_id
  private_subnet_app_ids             = module.networking.private_subnet_app_ids
  app_security_group_id              = module.security.app_security_group_id
  waf_web_acl_arn                    = module.security.waf_web_acl_arn
  common_tags                        = local.common_tags

  depends_on = [module.security, module.database, module.messaging, module.ml_pipeline, module.cache]
}

#===============================================================================
# OPERATIONS — Monitoring, alerting, compliance, and best practices
#===============================================================================

module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix                   = local.name_prefix
  environment                   = local.environment
  cloudwatch_dashboard_api      = var.monitoring.cloudwatch_dashboard_api
  cloudwatch_dashboard_ml       = var.monitoring.cloudwatch_dashboard_ml
  cloudwatch_dashboard_business = var.monitoring.cloudwatch_dashboard_business
  alarm_playlist_latency_ms     = var.monitoring.alarm_playlist_latency_ms
  alarm_api_5xx_pct             = var.monitoring.alarm_api_5xx_pct
  alarm_sagemaker_error_pct     = var.monitoring.alarm_sagemaker_error_pct
  alarm_dlq_message_count       = var.monitoring.alarm_dlq_message_count
  xray_tracing_enabled          = var.monitoring.xray_tracing_enabled
  log_retention_days            = var.monitoring.log_retention_days
  canary_interval_minutes       = var.monitoring.canary_interval_minutes
  apigw_id                      = module.api_service.api_gateway_id
  sagemaker_nlp_endpoint_name   = var.compute.sagemaker_nlp_endpoint_name
  sagemaker_audio_endpoint_name = var.compute.sagemaker_audio_endpoint_name
  feedback_dlq_name             = module.messaging.feedback_dlq_name
  common_tags                   = local.common_tags

  depends_on = [module.api_service, module.messaging, module.ml_pipeline]
}

module "best_practices" {
  source = "../../modules/best-practices"

  name_prefix               = local.name_prefix
  environment               = local.environment
  aws_config_enabled        = var.operations.aws_config_enabled
  security_hub_enabled      = var.operations.security_hub_enabled
  codepipeline_name         = var.operations.codepipeline_name
  codebuild_compute_type    = var.operations.codebuild_compute_type
  sns_topic_arn             = module.monitoring.sns_topic_arn
  common_tags               = local.common_tags

  depends_on = [module.monitoring]
}

#===============================================================================
# INTEGRATIONS — Cross-module wiring (avoids circular dependencies)
#===============================================================================

# WAF association with API Gateway REST API stage
resource "aws_wafv2_web_acl_association" "api_gateway" {
  count        = var.security.waf_enabled ? 1 : 0
  resource_arn = module.api_service.api_gateway_stage_arn
  web_acl_arn  = module.security.waf_web_acl_arn

  depends_on = [module.api_service, module.security]
}

# API Gateway p95 latency alarm — links monitoring SNS to API Gateway metric
resource "aws_cloudwatch_metric_alarm" "api_p95_latency" {
  alarm_name          = "${local.name_prefix}-api-p95-latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "IntegrationLatency"
  namespace           = "AWS/ApiGateway"
  period              = 60
  extended_statistic  = "p95"
  threshold           = var.monitoring.alarm_playlist_latency_ms
  alarm_description   = "API Gateway p95 integration latency exceeds ${var.monitoring.alarm_playlist_latency_ms}ms"
  alarm_actions       = [module.monitoring.sns_topic_arn]
  ok_actions          = [module.monitoring.sns_topic_arn]
  dimensions = {
    ApiName = module.api_service.api_gateway_name
    Stage   = var.compute.apigw_stage_name
  }

  depends_on = [module.api_service, module.monitoring]
}

# API Gateway 5xx error rate alarm
resource "aws_cloudwatch_metric_alarm" "api_5xx_rate" {
  alarm_name          = "${local.name_prefix}-api-5xx-rate"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Average"
  threshold           = var.monitoring.alarm_api_5xx_pct / 100
  alarm_description   = "API Gateway 5xx error rate exceeds ${var.monitoring.alarm_api_5xx_pct}%"
  alarm_actions       = [module.monitoring.sns_topic_arn]
  ok_actions          = [module.monitoring.sns_topic_arn]
  dimensions = {
    ApiName = module.api_service.api_gateway_name
    Stage   = var.compute.apigw_stage_name
  }

  depends_on = [module.api_service, module.monitoring]
}

# SQS DLQ message count alarm
resource "aws_cloudwatch_metric_alarm" "feedback_dlq_depth" {
  alarm_name          = "${local.name_prefix}-feedback-dlq-depth"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = var.monitoring.alarm_dlq_message_count
  alarm_description   = "Feedback DLQ message count exceeds ${var.monitoring.alarm_dlq_message_count}"
  alarm_actions       = [module.monitoring.sns_topic_arn]
  dimensions = {
    QueueName = module.messaging.feedback_dlq_name
  }

  depends_on = [module.messaging, module.monitoring]
}
