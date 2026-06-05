#------------------------------------------------------------------------------
# Production Environment — Variable Declarations
# Values supplied at deploy time via config/*.tfvars (generated from configuration.csv)
#------------------------------------------------------------------------------

variable "solution" {
  description = "Solution identity and project configuration"
  type = object({
    name        = string
    region      = string
    environment = string
    version     = string
    cost_center = string
    deadline    = string
  })
}

variable "application" {
  description = "Application configuration"
  type = object({
    name                       = string
    log_level                  = string
    port                       = number
    timeout_seconds            = number
    cli_package_name           = string
    cli_subcommand_count       = number
    api_route_count            = number
    artifact_types_count       = number
    agent_count                = number
    max_retries_per_artifact   = number
    generation_timeout_minutes = number
  })
}

variable "compute" {
  description = "Lambda and ECR compute configuration"
  type = object({
    ecr_repository_name                  = string
    ecr_agent_image_uri                  = string
    lambda_runtime                       = string
    lambda_architecture                  = string
    xray_tracing                         = string
    api_handler_memory_mb                = number
    api_handler_timeout_seconds          = number
    generation_initiator_memory_mb       = number
    generation_initiator_timeout_seconds = number
    agent_trigger_memory_mb              = number
    agent_trigger_timeout_seconds        = number
    cognito_trigger_memory_mb            = number
    cognito_trigger_timeout_seconds      = number
    github_push_memory_mb                = number
    github_push_timeout_seconds          = number
    total_function_count                 = number
    provisioned_concurrency_agent_triggers = number
  })
}

variable "bedrock" {
  description = "Bedrock AI model configuration"
  type = object({
    primary_model_id              = string
    validator_model_id            = string
    agentcore_runtime_region      = string
    input_tokens_monthly_sonnet   = number
    output_tokens_monthly_sonnet  = number
    cost_per_solution_target_usd  = number
  })
}

variable "database" {
  description = "DynamoDB table configuration"
  type = object({
    users_table_name          = string
    solutions_table_name      = string
    quotas_table_name         = string
    audit_events_table_name   = string
    billing_mode              = string
    pitr_enabled              = bool
    audit_events_ttl_days     = number
    quota_per_user_monthly    = number
    quota_global_monthly      = number
    inactive_user_suspension_days = number
  })
}

variable "security" {
  description = "Security and compliance configuration"
  type = object({
    cognito_user_pool_name               = string
    cognito_access_token_expiry_seconds  = number
    cognito_refresh_token_expiry_days    = number
    cognito_mfa_enabled                  = bool
    cognito_cto_signoff_required         = bool
    kms_rotation_days                    = number
    access_analyzer_enabled              = bool
    guardduty_enabled                    = bool
    securityhub_enabled                  = bool
    cloudtrail_management_events         = bool
    cloudtrail_s3_data_events            = bool
    cloudtrail_retention_days            = number
    tls_minimum_version                  = string
  })
}

variable "networking" {
  description = "VPC and network configuration"
  type = object({
    region                          = string
    vpc_cidr                        = string
    public_subnet_cidrs             = list(string)
    private_subnet_cidrs            = list(string)
    database_subnet_cidrs           = list(string)
    availability_zones              = list(string)
    nat_gateway_count               = number
    vpc_endpoint_s3                 = bool
    vpc_endpoint_dynamodb           = bool
    vpc_endpoint_secrets_manager    = bool
    vpc_endpoint_bedrock_runtime    = bool
    apigw_throttle_rps_burst        = number
  })
}

variable "storage" {
  description = "S3 storage configuration"
  type = object({
    artifact_bucket_name               = string
    guidance_bucket_name               = string
    cloudtrail_bucket_name             = string
    artifact_bucket_versioning_enabled = bool
    artifact_standard_retention_days   = number
    artifact_glacier_retention_days    = number
  })
}

variable "integration" {
  description = "GitHub and external integration configuration"
  type = object({
    github_repository_url   = string
    github_secret_arn       = string
    github_pat_rotation_days = number
    github_push_retry_count = number
    github_dlq_name         = string
  })
}

variable "monitoring" {
  description = "CloudWatch monitoring and alerting configuration"
  type = object({
    cloudwatch_dashboard_name        = string
    cloudtrail_bucket_name           = string
    cloudtrail_retention_days        = number
    cloudtrail_s3_data_events        = bool
    log_retention_lambda_days        = number
    xray_sampling_rate               = number
    alarm_lambda_error_rate_pct      = number
    alarm_bedrock_throttle_count     = number
    alarm_global_quota_threshold_pct = number
    api_gateway_p99_latency_ms       = number
    alert_email_subscriptions        = list(string)
  })
}

variable "operations" {
  description = "Operational and DR configuration"
  type = object({
    backup_enabled                = bool
    rto_hours                     = number
    rpo_hours                     = number
    scaling_min_solutions_monthly = number
    scaling_max_solutions_monthly = number
    hypercare_duration_weeks      = number
    cicd_pipeline_tool            = string
    terraform_validate_gate       = bool
    peer_review_required          = bool
    availability_target_pct       = number
    artifact_pass_rate_target_pct = number
    quota_bypass_incidents_target = number
  })
}
