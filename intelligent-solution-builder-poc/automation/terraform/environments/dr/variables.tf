###############################################################################
# DR Environment — Variable Declarations
###############################################################################

variable "project" {
  description = "Project identity and AWS region configuration"
  type = object({
    solution_name = string
    region        = string
    cost_center   = string
    environment   = string
    version       = string
  })
}

variable "application" {
  description = "Application runtime configuration"
  type = object({
    name                       = string
    version                    = string
    log_level                  = string
    presigned_url_expiry_seconds = number
    max_concurrent_jobs        = number
    job_timeout_minutes        = number
  })
}

variable "network" {
  description = "VPC and networking configuration"
  type = object({
    vpc_cidr             = string
    public_subnet_cidrs  = list(string)
    private_subnet_cidrs = list(string)
    nat_gateway_count    = number
    enable_privatelink_endpoints = bool
  })
}

variable "security" {
  description = "Security, WAF, Cognito, and CloudTrail configuration"
  type = object({
    enable_waf                      = bool
    waf_rate_limit_per_5_min        = number
    cognito_user_pool_domain        = string
    cognito_access_token_expiry_hours = number
    cognito_user_groups             = list(string)
    cognito_callback_urls           = list(string)
    cognito_logout_urls             = list(string)
    cloudtrail_enabled              = bool
    cloudtrail_include_data_events  = bool
    kms_key_rotation_enabled        = bool
    tls_minimum_version             = string
  })
}

variable "compute" {
  description = "Lambda and Step Functions compute configuration"
  type = object({
    lambda_architecture                     = string
    ecr_repository_prefix                   = string
    ecr_image_tag_mutability                = string
    stepfunctions_workflow_name             = string
    stepfunctions_max_retry_attempts        = number
    stepfunctions_retry_backoff_rate        = number
    stepfunctions_retry_interval_seconds    = number
    brief_submission_memory_mb              = number
    brief_submission_timeout_seconds        = number
    brief_submission_reserved_concurrency   = number
    brief_submission_provisioned_concurrency = number
    job_status_memory_mb                    = number
    job_status_timeout_seconds              = number
    job_status_reserved_concurrency         = number
    job_status_provisioned_concurrency      = number
    artifact_retrieval_memory_mb            = number
    artifact_retrieval_timeout_seconds      = number
    artifact_retrieval_reserved_concurrency = number
    admin_governance_memory_mb              = number
    admin_governance_timeout_seconds        = number
    admin_governance_reserved_concurrency   = number
    bedrock_orchestration_memory_mb         = number
    bedrock_orchestration_timeout_seconds   = number
    bedrock_orchestration_reserved_concurrency = number
    output_validation_memory_mb             = number
    output_validation_timeout_seconds       = number
    output_validation_reserved_concurrency  = number
    artifact_template_memory_mb             = number
    artifact_template_timeout_seconds       = number
    artifact_template_reserved_concurrency  = number
    ses_notification_memory_mb              = number
    ses_notification_timeout_seconds        = number
    health_check_memory_mb                  = number
  })
}

variable "storage" {
  description = "S3 and DynamoDB storage configuration"
  type = object({
    artifacts_bucket_name         = string
    terraform_state_bucket        = string
    cloudtrail_bucket             = string
    solution_state_table          = string
    usage_tracking_table          = string
    terraform_lock_table          = string
    audit_table                   = string
    s3_versioning_enabled         = bool
    s3_intelligent_tiering_days   = number
    s3_glacier_transition_days    = number
    pitr_enabled                  = bool
    enable_s3_replication         = bool
    s3_replication_role_arn       = string
    dr_replication_bucket_arn     = string
    dr_replication_kms_key_arn    = string
    solution_record_ttl_days      = number
  })
}

variable "ai" {
  description = "Amazon Bedrock configuration"
  type = object({
    bedrock_model_id              = string
    bedrock_region                = string
    max_tokens_per_artifact       = number
    monthly_token_quota           = number
    prompt_templates_s3_prefix    = string
    output_validation_max_retries = number
  })
}

variable "integration" {
  description = "SQS queue and SES integration configuration"
  type = object({
    sqs_generation_queue_name     = string
    sqs_dlq_name                  = string
    sqs_message_retention_seconds = number
    sqs_max_receive_count         = number
    ses_notification_template     = string
  })
}

variable "monitoring" {
  description = "CloudWatch observability configuration"
  type = object({
    cloudwatch_dashboard_name         = string
    log_retention_days                = number
    synthetics_canary_interval_minutes = number
    api_error_rate_threshold_pct      = number
    dlq_message_threshold             = number
    sfn_failure_threshold             = number
    bedrock_quota_threshold_pct       = number
    lambda_error_rate_threshold_pct   = number
    api_latency_p95_threshold_ms      = number
    xray_enabled                      = bool
    xray_sampling_rate                = number
  })
}
