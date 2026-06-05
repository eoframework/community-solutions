#------------------------------------------------------------------------------
# Amatra Agentic Pre-Sales Platform — Production Variables
#------------------------------------------------------------------------------

variable "project" {
  description = "Project identity and region configuration"
  type = object({
    solution_name               = string
    region                      = string
    environment                 = string
    opportunity_id              = string
    artifact_retention_days     = number
    monthly_quota_global        = number
    monthly_quota_per_user      = number
  })
}

variable "application" {
  description = "Application-level settings"
  type = object({
    name                        = string
    version                     = string
    log_level                   = string
    max_artifacts_per_solution  = number
    validation_retry_limit      = number
    generation_timeout_minutes  = number
  })
}

variable "network" {
  description = "VPC and networking configuration"
  type = object({
    vpc_cidr                  = string
    subnet_private_az1_cidr   = string
    subnet_private_az2_cidr   = string
    subnet_private_az3_cidr   = string
    subnet_public_cidr        = string
    nat_gateway_count         = number
    vpc_endpoints_enabled     = bool
  })
}

variable "security" {
  description = "Security and encryption configuration"
  type = object({
    enable_encryption_at_rest       = bool
    tls_minimum_version             = string
    guardduty_enabled               = bool
    cloudtrail_enabled              = bool
    cloudtrail_retention_days       = number
    cognito_user_pool_name          = string
    cognito_token_refresh_ttl_days  = number
    cognito_access_token_ttl_hours  = number
    cognito_mfa_enabled             = bool
    github_pat_secret_name          = string
    cognito_secret_name             = string
  })
}

variable "compute" {
  description = "Lambda and compute resource configuration"
  type = object({
    lambda_memory_mb                        = number
    lambda_timeout_seconds                  = number
    lambda_reserved_concurrency             = number
    stepfunctions_execution_timeout_seconds = number
    ecr_repository_name                     = string
    ecr_image_retention_count               = number
  })
}

variable "database" {
  description = "DynamoDB configuration"
  type = object({
    table_user_profiles     = string
    table_solution_state    = string
    table_quota_global      = string
    billing_mode            = string
    pitr_enabled            = bool
    solution_state_ttl_days = number
  })
}

variable "storage" {
  description = "S3 storage configuration"
  type = object({
    versioning_enabled      = bool
    glacier_transition_days = number
    enforce_ssl             = bool
  })
}

variable "bedrock" {
  description = "Amazon Bedrock model configuration"
  type = object({
    generation_model_id            = string
    validation_model_id            = string
    max_tokens_per_call            = number
    monthly_token_budget_millions  = number
  })
}

variable "monitoring" {
  description = "CloudWatch monitoring and alerting configuration"
  type = object({
    cloudwatch_dashboard_name                    = string
    log_retention_days                           = number
    metrics_namespace                            = string
    lambda_error_rate_alarm_threshold            = number
    stepfunctions_failure_rate_alarm_threshold   = number
    bedrock_daily_spend_alarm_pct                = number
    token_usage_metric_name                      = string
  })
}

variable "operations" {
  description = "Operational settings"
  type = object({
    backup_enabled                = bool
    quota_reset_schedule          = string
    scaling_min_lambda_concurrency = number
    scaling_max_lambda_concurrency = number
    rto_hours                     = number
    rpo_hours                     = number
    hypercare_weeks               = number
  })
}

variable "cicd" {
  description = "CI/CD pipeline configuration"
  type = object({
    codepipeline_name       = string
    codebuild_compute_type  = string
    terraform_validate_gate = bool
  })
}

variable "agentcore" {
  description = "Bedrock AgentCore agent configuration"
  type = object({
    agent_count = number
  })
}
