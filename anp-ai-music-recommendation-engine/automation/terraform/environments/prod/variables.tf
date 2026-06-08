#------------------------------------------------------------------------------
# ANP Streaming AI Recommendation Engine — Shared Variable Declarations
# All values are supplied via config/*.tfvars (generated from configuration.csv)
# Do NOT set default values for sensitive / environment-specific parameters.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Project
#------------------------------------------------------------------------------
variable "project" {
  description = "Core project identity and ownership configuration"
  type = object({
    solution_name    = string
    application_name = string
    region           = string
    environment      = string
    cost_center      = string
    opportunity_no   = string
    aws_profile      = optional(string, "")
  })
}

#------------------------------------------------------------------------------
# Networking
#------------------------------------------------------------------------------
variable "networking" {
  description = "VPC and subnet configuration"
  type = object({
    vpc_cidr                  = string
    public_subnet_az1         = string
    public_subnet_az2         = string
    private_subnet_app_az1    = string
    private_subnet_app_az2    = string
    private_subnet_data_az1   = string
    private_subnet_data_az2   = string
    nat_gateway_count         = number
    vpc_gateway_endpoints     = list(string)
  })
}

#------------------------------------------------------------------------------
# Security
#------------------------------------------------------------------------------
variable "security" {
  description = "Security controls including KMS, Cognito, WAF, GuardDuty"
  type = object({
    cognito_token_expiry_minutes      = number
    cognito_mfa_enabled               = bool
    kms_catalog_cmk_alias             = string
    kms_user_data_cmk_alias           = string
    kms_model_artifacts_cmk_alias     = string
    kms_rotation_enabled              = bool
    secrets_rotation_days             = number
    tls_minimum_version               = string
    waf_enabled                       = bool
    guardduty_enabled                 = bool
    cloudtrail_enabled                = bool
    iam_access_analyzer_enabled       = bool
    log_retention_days                = number
  })
}

#------------------------------------------------------------------------------
# Compute
#------------------------------------------------------------------------------
variable "compute" {
  description = "Lambda, API Gateway, and SageMaker compute sizing"
  type = object({
    lambda_architecture                     = string
    lambda_playlist_memory_mb               = number
    lambda_playlist_timeout_seconds         = number
    lambda_enrichment_memory_mb             = number
    lambda_enrichment_timeout_seconds       = number
    lambda_authorizer_memory_mb             = number
    lambda_authorizer_timeout_seconds       = number
    lambda_feedback_memory_mb               = number
    lambda_preference_update_memory_mb      = number
    lambda_max_concurrency                  = number
    apigw_stage_name                        = string
    apigw_integration_timeout_ms            = number
    apigw_rate_limit_rps                    = number
    sagemaker_nlp_endpoint_name             = string
    sagemaker_nlp_instance_type             = string
    sagemaker_audio_endpoint_name           = string
    sagemaker_audio_instance_type           = string
    sagemaker_training_instance_type        = string
    sagemaker_training_use_spot             = bool
    sagemaker_min_instances                 = number
    sagemaker_scale_threshold_pct           = number
    opensearch_instance_type                = string
    opensearch_volume_gb                    = number
    elasticache_node_type                   = string
  })
}

#------------------------------------------------------------------------------
# Database
#------------------------------------------------------------------------------
variable "database" {
  description = "DynamoDB table names and configuration"
  type = object({
    content_catalog_table      = string
    user_profile_table         = string
    interaction_events_table   = string
    mood_taxonomy_table        = string
    billing_mode               = string
    pitr_enabled               = bool
    interaction_retention_days = number
  })
}

#------------------------------------------------------------------------------
# Cache
#------------------------------------------------------------------------------
variable "cache" {
  description = "ElastiCache Redis configuration"
  type = object({
    port                 = number
    playlist_ttl_seconds = number
    session_ttl_seconds  = number
    enabled              = bool
  })
}

#------------------------------------------------------------------------------
# Application
#------------------------------------------------------------------------------
variable "application" {
  description = "Application-level settings"
  type = object({
    name                     = string
    version                  = string
    log_level                = string
    api_version              = string
    playlist_count_default   = number
    cold_start_threshold     = number
  })
}

#------------------------------------------------------------------------------
# Integration
#------------------------------------------------------------------------------
variable "integration" {
  description = "External and internal integration configuration"
  type = object({
    firebase_api_url                          = string
    firebase_timeout_ms                       = number
    bedrock_model_id                          = string
    bedrock_max_tokens                        = number
    sqs_feedback_queue_retention_seconds      = number
    sqs_max_receive_count                     = number
    eventbridge_catalog_bus_name              = string
  })
}

#------------------------------------------------------------------------------
# Storage
#------------------------------------------------------------------------------
variable "storage" {
  description = "S3 bucket names and lifecycle configuration"
  type = object({
    raw_catalog_bucket     = string
    transcripts_bucket     = string
    features_bucket        = string
    models_bucket          = string
    cloudtrail_bucket      = string
    lifecycle_ia_days      = number
    lifecycle_glacier_days = number
    versioning_enabled     = bool
  })
}

#------------------------------------------------------------------------------
# ML / AI
#------------------------------------------------------------------------------
variable "ml" {
  description = "Machine learning pipeline configuration"
  type = object({
    mood_taxonomy_min_labels       = number
    classifier_confidence_threshold = number
    classifier_accuracy_target_pct  = number
    retraining_schedule_expression  = string
    retraining_conditional_promotion = bool
    personalize_min_interactions    = number
    sagemaker_model_registry_name   = string
    sagemaker_max_versions_retained = number
  })
}

#------------------------------------------------------------------------------
# Monitoring
#------------------------------------------------------------------------------
variable "monitoring" {
  description = "CloudWatch dashboards, alarms, and observability configuration"
  type = object({
    cloudwatch_dashboard_api       = string
    cloudwatch_dashboard_ml        = string
    cloudwatch_dashboard_business  = string
    alarm_playlist_latency_ms      = number
    alarm_api_5xx_pct              = number
    alarm_sagemaker_error_pct      = number
    alarm_dlq_message_count        = number
    xray_tracing_enabled           = bool
    log_retention_days             = number
    canary_interval_minutes        = number
  })
}

#------------------------------------------------------------------------------
# Operations
#------------------------------------------------------------------------------
variable "operations" {
  description = "Operational settings including CI/CD and tagging"
  type = object({
    rto_hours                = number
    rpo_hours                = number
    codepipeline_name        = string
    codebuild_compute_type   = string
    support_plan             = string
    aws_config_enabled       = bool
    security_hub_enabled     = bool
    tagging_environment      = string
    tagging_application      = string
    tagging_cost_center      = string
  })
}
