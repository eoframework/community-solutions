#------------------------------------------------------------------------------
# ANP Streaming AI - Test Variables (identical structure to prod)
#------------------------------------------------------------------------------

variable "solution" {
  description = "Solution identity and project metadata"
  type = object({
    name           = string
    region_primary = string
    environment    = string
    opportunity_id = string
  })
}

variable "aws" {
  description = "AWS provider configuration"
  type = object({
    region = string
  })
}

variable "application" {
  description = "Application-level configuration"
  type = object({
    name                    = string
    version                 = string
    log_level               = string
    api_stage               = string
    mood_labels             = string
    recommend_default_limit = number
    recommend_max_limit     = number
    api_timeout_seconds     = number
  })
}

variable "compute" {
  description = "Compute resource configuration (Lambda + API Gateway)"
  type = object({
    lambda_runtime = string

    classifier_function_name           = string
    classifier_memory_mb               = number
    classifier_timeout_seconds         = number
    classifier_provisioned_concurrency = number
    bedrock_max_tokens                 = number

    recommender_function_name   = string
    recommender_memory_mb       = number
    recommender_timeout_seconds = number
    history_lookback            = number

    autotagger_function_name   = string
    autotagger_memory_mb       = number
    autotagger_timeout_seconds = number
    autotagger_max_retries     = number
    autotagger_dlq_name        = string

    apigw_api_name       = string
    apigw_rate_limit_rps = number
    apigw_burst_limit    = number
  })
}

variable "database" {
  description = "DynamoDB table configuration"
  type = object({
    catalog_table_name       = string
    billing_mode             = string
    catalog_pitr_enabled     = bool
    catalog_gsi_name         = string
    min_confidence_threshold = number

    user_history_table_name    = string
    user_history_pitr_enabled  = bool
    user_history_ttl_attribute = string
    user_history_ttl_days      = number
  })
}

variable "storage" {
  description = "S3 storage configuration"
  type = object({
    catalog_bucket_name = string
    catalog_prefix      = string
    versioning_enabled  = bool
    encryption          = string
    size_limit_gb       = number
  })
}

variable "security" {
  description = "Security controls configuration"
  type = object({
    secret_rotation_days      = number
    iam_mfa_required          = bool
    https_only                = bool
    tls_minimum_version       = string
    cloudtrail_enabled        = bool
    cloudtrail_retention_days = number
  })
}

variable "integration" {
  description = "External service integration configuration"
  type = object({
    cognito_user_pool_id         = string
    cognito_user_pool_arn        = string
    cognito_jwt_expiry_seconds   = number
    firebase_export_s3_prefix    = string
    bedrock_monthly_token_budget = number
  })
}

variable "monitoring" {
  description = "Monitoring and observability configuration"
  type = object({
    dashboard_operations = string
    dashboard_cost       = string
    log_retention_days   = number
    xray_enabled         = bool

    lambda_error_threshold   = number
    apigw_p95_latency_ms     = number
    apigw_5xx_count          = number
    autotagger_dlq_depth     = number
    bedrock_token_budget_pct = number
    dynamodb_throttle_count  = number

    classifier_error_rate_pct  = number
    recommender_error_rate_pct = number
  })
}

variable "operations" {
  description = "Operational metadata and tagging"
  type = object({
    tagging_project     = string
    tagging_cost_center = string
    tagging_managed_by  = string

    lambda_alias                = string
    rollback_trigger_error_pct  = number
    rollback_trigger_latency_ms = number
    availability_target_pct     = number
    rto_minutes                 = number
    rpo_hours                   = number
  })
}
