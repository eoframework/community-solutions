variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
}

variable "networking" {
  description = "API Gateway and networking configuration"
  type = object({
    api_gateway_stage_name           = string
    api_gateway_throttle_burst_limit = number
    api_gateway_throttle_rate_limit  = number
    api_gateway_custom_domain        = string
    api_gateway_tls_minimum_version  = string
  })
}

variable "compute" {
  description = "Lambda compute configuration"
  type = object({
    lambda_runtime                          = string
    solution_create_memory_mb               = number
    solution_create_timeout_seconds         = number
    solution_create_concurrency_limit       = number
    solution_create_provisioned_concurrency = number
    status_memory_mb                        = number
    status_timeout_seconds                  = number
    artifact_fetch_memory_mb                = number
    artifact_fetch_timeout_seconds          = number
    admin_usage_memory_mb                   = number
    admin_usage_timeout_seconds             = number
    github_integration_memory_mb            = number
    github_integration_timeout_seconds      = number
    github_integration_concurrency_limit    = number
    post_confirmation_memory_mb             = number
    post_confirmation_timeout_seconds       = number
    agentcore_agents_count                  = number
    agentcore_max_concurrency_per_agent     = number
    agentcore_image_tag_policy              = string
  })
}

variable "application" {
  description = "Application configuration"
  type = object({
    name                            = string
    version                         = string
    log_level                       = string
    cli_package_name                = string
    cli_subcommand_count            = number
    max_solution_generation_minutes = number
    artifact_types_count            = number
  })
}

variable "integration" {
  description = "Bedrock and GitHub integration configuration"
  type = object({
    bedrock_generation_model_id               = string
    bedrock_validation_model_id               = string
    bedrock_max_retries_per_artifact          = number
    bedrock_generation_retry_initial_delay_ms = number
    bedrock_target_cost_per_solution_usd      = number
    github_repository_url                     = string
    github_commit_retry_count                 = number
    github_branch                             = string
  })
}

variable "security" {
  description = "Security configuration"
  type = object({
    cognito_user_pool_name                    = string
    cognito_access_token_expiry_seconds       = number
    cognito_refresh_token_expiry_days         = number
    cognito_mfa_enabled                       = bool
    cognito_group_consultants                 = string
    cognito_group_admins                      = string
    waf_rate_limit_requests_per_ip_per_minute = number
    waf_managed_rules_enabled                 = bool
    github_pat_secret_name                    = string
    cloudtrail_enabled                        = bool
    cloudtrail_s3_bucket_name                 = string
    iam_wildcard_resource_arns_allowed        = bool
  })
}

variable "storage" {
  description = "Storage configuration"
  type = object({
    artifacts_bucket_name               = string
    artifacts_versioning_enabled        = bool
    artifacts_intelligent_tiering_days  = number
    artifacts_prefix_raw                = string
    artifacts_prefix_converted          = string
    terraform_prefix                    = string
    guidance_bucket_name                = string
    ecr_repository_name                 = string
    ecr_image_scan_on_push              = bool
  })
}

variable "database" {
  description = "Database configuration"
  type = object({
    billing_mode            = string
    pitr_enabled            = bool
    users_table_name        = string
    solutions_table_name    = string
    global_quota_table_name = string
    encryption_key_alias    = string
  })
}

variable "quota" {
  description = "Quota configuration"
  type = object({
    user_monthly_solution_limit   = number
    global_monthly_solution_limit = number
    global_alert_threshold_pct    = number
    user_alert_threshold_count    = number
  })
}

variable "monitoring" {
  description = "Monitoring configuration"
  type = object({
    log_retention_days             = number
    cloudtrail_log_retention_days  = number
    dashboard_platform_health      = string
    dashboard_throughput           = string
    dashboard_cost_telemetry       = string
    dashboard_quota_utilisation    = string
    xray_tracing_enabled           = bool
    canary_endpoint_path           = string
    canary_interval_minutes        = number
    sns_topic_name                 = string
    lambda_error_rate_threshold_pct    = number
    bedrock_cost_anomaly_threshold_usd = number
  })
}

variable "operations" {
  description = "Operations configuration"
  type = object({
    terraform_state_bucket_name               = string
    terraform_state_lock_table_name           = string
    backup_dynamodb_pitr_recovery_window_days = number
    backup_s3_version_retention_days          = number
    lambda_reserved_concurrency_total         = number
    codebuild_agent_image_project_name        = string
    codebuild_terraform_plan_project_name     = string
    ssm_s3_artifacts_bucket_param             = string
    ssm_dynamodb_solutions_table_param        = string
  })
}
