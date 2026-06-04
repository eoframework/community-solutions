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
