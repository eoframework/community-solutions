#------------------------------------------------------------------------------
# Amatra ISB — DR Environment Variables
#------------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Project / Identity
# ---------------------------------------------------------------------------
variable "solution" {
  description = "Solution identity and metadata"
  type = object({
    name          = string
    abbr          = string
    provider_name = string
    category_name = string
    version       = string
    opportunity_id = string
  })
}

variable "aws" {
  description = "AWS account and region configuration"
  type = object({
    region  = string
    profile = optional(string, "")
  })
}

variable "ownership" {
  description = "Resource ownership and cost allocation metadata"
  type = object({
    cost_center   = string
    owner_email   = string
    project_code  = string
    phase         = string
    compliance    = string
  })
}

# ---------------------------------------------------------------------------
# Application
# ---------------------------------------------------------------------------
variable "application" {
  description = "Application-level configuration for the ISB platform"
  type = object({
    name                     = string
    log_level                = string
    artifact_types           = list(string)
    api_version              = string
    presigned_url_ttl_seconds = number
    max_brief_size_kb        = number
  })
}

# ---------------------------------------------------------------------------
# Compute (Lambda)
# ---------------------------------------------------------------------------
variable "compute" {
  description = "Lambda function sizing and concurrency configuration"
  type = object({
    runtime = string
    api_submit = object({
      memory_mb                = number
      timeout_seconds          = number
      provisioned_concurrency  = number
    })
    api_status = object({
      memory_mb               = number
      timeout_seconds         = number
      provisioned_concurrency = number
    })
    api_retrieve = object({
      memory_mb               = number
      timeout_seconds         = number
      provisioned_concurrency = number
    })
    api_admin = object({
      memory_mb               = number
      timeout_seconds         = number
      provisioned_concurrency = number
    })
    orchestrator_start = object({
      memory_mb       = number
      timeout_seconds = number
    })
    bedrock_sonnet = object({
      memory_mb       = number
      timeout_seconds = number
    })
    bedrock_haiku = object({
      memory_mb       = number
      timeout_seconds = number
    })
    artifact_processor = object({
      memory_mb       = number
      timeout_seconds = number
    })
    reserved_concurrency_total = number
    lambda_alias               = string
  })
}

# ---------------------------------------------------------------------------
# Database (DynamoDB)
# ---------------------------------------------------------------------------
variable "database" {
  description = "DynamoDB table configuration for solution state and usage tracking"
  type = object({
    solution_state_table      = string
    usage_tracking_table      = string
    billing_mode              = string
    pitr_enabled              = bool
    ttl_solution_state_days   = number
    ttl_usage_tracking_days   = number
    encryption_key_alias      = string
  })
}

# ---------------------------------------------------------------------------
# Storage (S3)
# ---------------------------------------------------------------------------
variable "storage" {
  description = "S3 bucket configuration for artifacts, templates, and CloudTrail"
  type = object({
    artifacts_bucket_name                = string
    cloudtrail_bucket_name               = string
    templates_bucket_name                = string
    artifacts_lifecycle_standard_days    = number
    versioning_enabled                   = bool
    encryption_key_alias                 = string
  })
}

# ---------------------------------------------------------------------------
# Security
# ---------------------------------------------------------------------------
variable "security" {
  description = "Security service configuration — WAF, Cognito, GuardDuty, CloudTrail"
  type = object({
    cognito = object({
      admin_group_name    = string
      presales_group_name = string
      delivery_group_name = string
      mfa_enforcement     = string
      token_expiry_minutes = number
    })
    waf = object({
      rate_limit_per_ip_per_5min = number
    })
    s3_block_public_access  = bool
    guardduty_enabled       = bool
    securityhub_enabled     = bool
    cloudtrail_enabled      = bool
    cloudtrail_retention_years = number
    session_timeout_minutes = number
  })
}

# ---------------------------------------------------------------------------
# Integration
# ---------------------------------------------------------------------------
variable "integration" {
  description = "Integration configuration — API Gateway, Bedrock, SQS, Step Functions, Secrets Manager"
  type = object({
    api_gateway = object({
      stage_name           = string
      throttle_burst_rps   = number
      throttle_steady_rps  = number
      custom_domain        = string
    })
    bedrock = object({
      sonnet_model_id              = string
      haiku_model_id               = string
      max_input_tokens_monthly     = number
      max_output_tokens_monthly    = number
      retry_max_attempts           = number
      retry_interval_seconds       = number
    })
    sqs = object({
      job_queue_name             = string
      dlq_name                   = string
      visibility_timeout_seconds = number
      message_retention_seconds  = number
      max_receive_count          = number
    })
    stepfunctions = object({
      execution_history_days = number
    })
    secrets_manager = object({
      secret_prefix = string
    })
  })
}

# ---------------------------------------------------------------------------
# Monitoring
# ---------------------------------------------------------------------------
variable "monitoring" {
  description = "CloudWatch monitoring, dashboards, alarms, and Synthetics configuration"
  type = object({
    cloudwatch = object({
      operations_dashboard  = string
      sla_dashboard         = string
      quality_dashboard     = string
      log_retention_days    = number
    })
    alarm = object({
      job_failure_rate_threshold_pct = number
      api_5xx_threshold_pct          = number
      bedrock_budget_warning_pct     = number
      dlq_depth_threshold            = number
      cognito_auth_failure_pct       = number
    })
    synthetics = object({
      health_check_interval_seconds = number
    })
  })
}

# ---------------------------------------------------------------------------
# Operations
# ---------------------------------------------------------------------------
variable "operations" {
  description = "Operational configuration — usage limits, CI/CD, backup, QA"
  type = object({
    usage_limit = object({
      per_user_monthly_default  = number
      global_monthly_default    = number
    })
    backup = object({
      cognito_export_schedule     = string
      dynamodb_pitr_window_days   = number
    })
    cicd = object({
      github_repo                 = string
      production_approval_required = bool
    })
    qa = object({
      first_pass_target_pct = number
    })
  })
}
