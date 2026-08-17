#------------------------------------------------------------------------------
# DR Environment Variables
# AWS Multi-Account Landing Zone
#------------------------------------------------------------------------------

variable "solution" {
  description = "Solution identity and metadata"
  type = object({
    name          = string
    abbr          = string
    version       = string
    provider_name = string
    category_name = string
  })
}

variable "project" {
  description = "Project deployment configuration"
  type = object({
    environment      = string
    region_primary   = string
    region_secondary = string
  })
}

variable "ownership" {
  description = "Ownership and cost allocation attributes"
  type = object({
    owner_team   = string
    cost_center  = string
    project_code = string
  })
}

variable "aws_accounts" {
  description = "AWS account IDs for landing zone accounts (sourced from Secrets Manager)"
  type = object({
    management_id      = string
    log_archive_id     = string
    audit_id           = string
    network_hub_id     = string
    shared_services_id = string
  })
  sensitive = true
}

variable "aws_org" {
  description = "AWS Organizations identifiers (sourced from Secrets Manager)"
  type = object({
    id      = string
    root_id = string
  })
  sensitive = true
}

variable "sso" {
  description = "IAM Identity Center configuration"
  type = object({
    instance_arn           = string
    identity_store_id      = string
    identity_source        = string
    session_duration_hours = number
  })
  sensitive = true
}

variable "security" {
  description = "Security control configuration"
  type = object({
    mfa_enabled                   = bool
    scp_deny_root_enabled         = bool
    scp_restrict_regions_enabled  = bool
    scp_cloudtrail_lock_enabled   = bool
    scp_config_lock_enabled       = bool
    rcp_data_perimeter_enabled    = bool
    kms_key_rotation_enabled      = bool
    tls_minimum_version           = string
    s3_block_public_access        = bool
    ebs_encryption_by_default     = bool
    breakglass_rotation_days      = number
  })
}

variable "networking" {
  description = "Network topology configuration"
  type = object({
    ipam_supernet_cidr           = string
    ipam_pool_us_east_1_cidr     = string
    ipam_pool_us_east_2_cidr     = string
    hub_vpc_us_east_1_cidr       = string
    hub_vpc_us_east_2_cidr       = string
    spoke_vpc_cidr_prefix_length = number
    nat_gateway_count_per_region = number
    vpc_flow_logs_enabled        = bool
    vpc_flow_logs_retention_days = number
  })
}

variable "logging" {
  description = "CloudTrail, Config, and log storage configuration"
  type = object({
    cloudtrail_trail_name                 = string
    cloudtrail_s3_retention_days_standard = number
    cloudtrail_lake_retention_years       = number
    cloudtrail_object_lock_retention_days = number
    config_recording_enabled              = bool
    config_conformance_pack_fsbp          = bool
    config_conformance_pack_nist          = bool
  })
}

variable "monitoring" {
  description = "CloudWatch, Security Hub, and GuardDuty configuration"
  type = object({
    securityhub_enabled                    = bool
    securityhub_fsbp_score_target          = number
    securityhub_delegated_admin_account_id = string
    guardduty_enabled                      = bool
    guardduty_delegated_admin_account_id   = string
    guardduty_alert_severity_threshold     = number
    cloudwatch_dashboard_name_ops          = string
    cloudwatch_dashboard_name_security     = string
    cloudwatch_dashboard_name_finops       = string
    cloudwatch_log_retention_days          = number
  })
  sensitive = true
}

variable "aft" {
  description = "Account Factory for Terraform pipeline configuration"
  type = object({
    pipeline_terraform_version               = string
    pipeline_codebuild_compute_type          = string
    pipeline_vending_sla_minutes             = number
    pipeline_max_concurrent_vending          = number
    customisation_mandatory_tags_env_key     = string
    customisation_mandatory_tags_owner_key   = string
    customisation_mandatory_tags_cc_key      = string
    customisation_mandatory_tags_project_key = string
    customisation_mandatory_tags_dataclass_key = string
    customisation_budget_alert_threshold_80  = number
    customisation_budget_alert_threshold_100 = number
  })
}

variable "storage" {
  description = "S3 and DynamoDB storage configuration"
  type = object({
    log_archive_bucket_name_primary     = string
    log_archive_bucket_name_replica     = string
    log_archive_glacier_transition_days = number
    terraform_state_bucket_name         = string
    terraform_state_dynamodb_lock_table = string
  })
  sensitive = true
}

variable "finops" {
  description = "FinOps and cost management configuration"
  type = object({
    cost_explorer_enabled          = bool
    cost_anomaly_detection_enabled = bool
    budgets_monthly_threshold_usd  = number
  })
}

variable "dr" {
  description = "Disaster Recovery configuration"
  type = object({
    rto_landing_zone_hours        = number
    rpo_log_archive_minutes       = number
    rto_network_firewall_minutes  = number
    rto_iam_identity_center_hours = number
  })
}
