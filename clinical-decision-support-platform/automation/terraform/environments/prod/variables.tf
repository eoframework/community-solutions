################################################################################
# Production Environment — Variable Declarations
# Values are supplied by config/*.tfvars (generated from configuration.csv).
# Do NOT hard-code values here — this file only declares types and descriptions.
################################################################################

# ---------------------------------------------------------------------------
# Project / Solution
# ---------------------------------------------------------------------------
variable "solution" {
  description = "Solution identity and project metadata"
  type = object({
    name           = string
    opportunity_no = string
    phase          = string
    environment    = string
  })
}

variable "project" {
  description = "AWS region and account configuration"
  type = object({
    primary_region = string
    dr_region      = string
  })
}

# ---------------------------------------------------------------------------
# Application
# ---------------------------------------------------------------------------
variable "application" {
  description = "Application-level configuration"
  type = object({
    name                   = string
    version                = string
    log_level              = string
    port                   = number
    timeout_seconds        = number
    concurrency_max        = number
    session_timeout_hours  = number
  })
}

# ---------------------------------------------------------------------------
# Compute
# ---------------------------------------------------------------------------
variable "compute" {
  description = "Compute sizing and ECS configuration"
  type = object({
    ecs_cluster_name             = string
    ecs_task_cpu                 = number
    ecs_task_memory_mb           = number
    ecs_scaling_min              = number
    ecs_scaling_max              = number
    dashboard_container_image    = optional(string, "public.ecr.aws/amazonlinux/amazonlinux:latest")
    api_container_image          = optional(string, "public.ecr.aws/amazonlinux/amazonlinux:latest")
    lambda_fhir_memory_mb        = number
    lambda_fhir_timeout_seconds  = number
    lambda_hl7_memory_mb         = number
    lambda_hl7_timeout_seconds   = number
    lambda_inference_memory_mb   = number
    lambda_alert_router_memory_mb = number
    sagemaker_sepsis_instance_type      = string
    sagemaker_sepsis_min_instances      = number
    sagemaker_sepsis_max_instances      = number
    sagemaker_readmission_instance_type = string
    sagemaker_readmission_min_instances = number
    sagemaker_rapid_response_instance_type = string
    sagemaker_rapid_response_min_instances = number
    sagemaker_training_instance_type    = string
  })
}

# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------
variable "database" {
  description = "RDS Aurora PostgreSQL configuration"
  type = object({
    aurora_cluster_identifier   = string
    aurora_instance_type        = string
    aurora_multi_az_enabled     = bool
    aurora_backup_retention_days = number
    aurora_db_name              = string
    aurora_master_username      = string
    aurora_ssl_mode             = string
    aurora_deletion_protection  = bool
  })
}

# ---------------------------------------------------------------------------
# Cache
# ---------------------------------------------------------------------------
variable "cache" {
  description = "ElastiCache Redis configuration"
  type = object({
    elasticache_cluster_id              = string
    elasticache_node_type               = string
    elasticache_multi_az_enabled        = bool
    elasticache_at_rest_encryption      = bool
    elasticache_ttl_patient_context_seconds = number
    elasticache_duplicate_suppression_ttl_seconds = number
  })
}

# ---------------------------------------------------------------------------
# Security
# ---------------------------------------------------------------------------
variable "security" {
  description = "Security and compliance configuration"
  type = object({
    kms_key_rotation_enabled       = bool
    mfa_enabled                    = bool
    audit_log_retention_years      = number
    cloudwatch_log_retention_days  = number
    waf_enabled                    = bool
    guardduty_enabled              = bool
    config_enabled                 = bool
    security_hub_enabled           = bool
    macie_enabled                  = bool
    iam_access_analyzer_enabled    = bool
    tls_minimum_version            = string
  })
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------
variable "networking" {
  description = "VPC and network topology configuration"
  type = object({
    vpc_cidr_primary               = string
    subnet_cidr_public_az1         = string
    subnet_cidr_public_az2         = string
    subnet_cidr_app_az1            = string
    subnet_cidr_app_az2            = string
    subnet_cidr_app_az3            = string
    subnet_cidr_data_az1           = string
    subnet_cidr_data_az2           = string
    nat_gateway_count              = number
    direct_connect_bandwidth_gbps  = number
    vpn_enabled                    = bool
    privatelink_endpoints_enabled  = bool
    certificate_arn                = optional(string, "")
  })
}

# ---------------------------------------------------------------------------
# Storage
# ---------------------------------------------------------------------------
variable "storage" {
  description = "S3 bucket and HealthLake storage configuration"
  type = object({
    datalake_bucket_name             = string
    audit_bucket_name                = string
    model_artefacts_bucket_name      = string
    object_lock_retention_years      = number
    cross_region_replication_enabled = bool
    healthlake_datastore_id          = string
    healthlake_fhir_version          = string
    healthlake_active_storage_tb     = number
    healthlake_retention_years       = number
    redshift_cluster_identifier      = string
    redshift_node_type               = string
    redshift_snapshot_retention_days = number
  })
}

# ---------------------------------------------------------------------------
# Integration
# ---------------------------------------------------------------------------
variable "integration" {
  description = "External system integration configuration"
  type = object({
    epic_fhir_subscription_resources = string
    epic_timeout_ms                  = number
    mirth_hl7_message_types          = string
    sql_server_export_schedule_cron  = string
  })
}

# ---------------------------------------------------------------------------
# ML Platform
# ---------------------------------------------------------------------------
variable "ml" {
  description = "ML Platform and inference configuration"
  type = object({
    kinesis_stream_name                = string
    kinesis_shard_count                = number
    kinesis_retention_hours            = number
    kinesis_dlq_alarm_threshold        = number
    msk_cluster_name                   = string
    msk_broker_count                   = number
    msk_broker_instance_type           = string
    msk_topic_partition_key            = string
    feature_store_online_group_name    = string
    feature_store_offline_group_name   = string
    feature_completeness_threshold     = number
    sepsis_auroc_threshold             = number
    sepsis_risk_score_alert_threshold  = number
    model_retraining_schedule_cron     = string
    model_registry_name                = string
    bedrock_model_id                   = string
    bedrock_max_tokens                 = number
    bedrock_timeout_ms                 = number
    bedrock_prompt_template_version    = string
    inference_latency_target_ms        = number
    sagemaker_latency_budget_ms        = number
    shap_enabled                       = bool
    concurrent_patients_max            = number
    inference_volume_monthly           = number
  })
}

# ---------------------------------------------------------------------------
# Monitoring
# ---------------------------------------------------------------------------
variable "monitoring" {
  description = "Observability and alerting configuration"
  type = object({
    cloudwatch_dashboard_name               = string
    cloudwatch_latency_alarm_threshold_ms   = number
    cloudwatch_ecs_cpu_alarm_threshold_pct  = number
    cloudwatch_alb_5xx_alarm_threshold_pct  = number
    datadog_site                            = string
    datadog_apm_enabled                     = bool
    datadog_host_count                      = number
    xray_enabled                            = bool
    quicksight_dashboard_name               = string
  })
}

# ---------------------------------------------------------------------------
# Operations
# ---------------------------------------------------------------------------
variable "operations" {
  description = "Operational and DR configuration"
  type = object({
    backup_aurora_retention_days         = number
    backup_elasticache_retention_days    = number
    backup_redshift_retention_days       = number
    dr_rto_hours                         = number
    dr_rpo_minutes                       = number
    dr_failover_test_schedule            = string
    ci_cd_pipeline_name                  = string
    ci_cd_rollback_latency_threshold_ms  = number
    ci_cd_snyk_scanning_enabled          = bool
    scaling_sagemaker_cpu_threshold_pct  = number
    alert_duplicate_suppression_minutes  = number
    facility_count                       = number
    clinical_users_mau                   = number
    compliance_config_remediation_critical_hours = number
    compliance_config_remediation_high_days      = number
    access_review_cadence_days           = number
    hypercare_duration_weeks             = number
  })
}
