#------------------------------------------------------------------------------
# AWS Cloud Governance Platform — Test Environment Variables
# All values are injected by the orchestrator from configuration.csv.
# DO NOT set defaults that contain secrets, account IDs, or credentials.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Solution / Project
#------------------------------------------------------------------------------
variable "solution" {
  description = "Solution identity, region, and environment metadata"
  type = object({
    name        = string
    environment = string
    region      = string
    dr_region   = string
    version     = string
  })
}

variable "ownership" {
  description = "Ownership and cost-attribution metadata applied to all resources"
  type = object({
    owner_team    = string
    cost_centre   = string
    project_code  = string
  })
}

#------------------------------------------------------------------------------
# Application / Pipeline
#------------------------------------------------------------------------------
variable "application" {
  description = "Application-level settings for the governance platform"
  type = object({
    log_level                            = string
    accounts_at_golive                   = number
    platform_users                       = number
    itsm_approval_required               = bool
    max_concurrent_requests              = number
    account_provisioning_timeout_minutes = number
  })
}

#------------------------------------------------------------------------------
# Database
#------------------------------------------------------------------------------
variable "database" {
  description = "DynamoDB table configuration for AFT workflow and Terraform state locking"
  type = object({
    aft_workflow_table_name      = string
    aft_workflow_billing_mode    = string
    aft_workflow_backup_enabled  = bool
    tf_state_lock_table          = string
  })
}

#------------------------------------------------------------------------------
# Security
#------------------------------------------------------------------------------
variable "security" {
  description = "Security controls: KMS, CloudTrail, session policy, SCP settings"
  type = object({
    kms_rotation_enabled              = bool
    cloudtrail_log_retention_years    = number
    cloudtrail_log_integrity_enabled  = bool
    mfa_enabled                       = bool
    session_timeout_minutes           = number
    console_access_blocked_in_prod    = bool
    credentials_rotation_days         = number
    access_review_frequency           = string
  })
}

variable "scp" {
  description = "Service Control Policy names and region-lock configuration"
  type = object({
    deny_console_access_policy_name  = string
    region_lock_allowed_regions      = list(string)
    encryption_enforce_policy_name   = string
  })
}

variable "identity" {
  description = "IAM Identity Center / SSO configuration"
  type = object({
    idp_connector_count              = number
    permission_set_developer         = string
    permission_set_operator          = string
    permission_set_security_viewer   = string
    breakglass_session_minutes       = number
  })
}

#------------------------------------------------------------------------------
# Integration
#------------------------------------------------------------------------------
variable "integration_siem" {
  description = "SIEM forwarding pipeline configuration (endpoints resolved from Secrets Manager)"
  type = object({
    delivery_sla_minutes        = number
    finding_severity_threshold  = string
    dlq_name                    = string
    dlq_alarm_threshold         = number
  })
}

variable "integration_itsm" {
  description = "ITSM change-approval integration configuration (secrets resolved from Secrets Manager)"
  type = object({
    approval_poll_interval_seconds  = number
    change_freeze_scp_condition     = bool
  })
}

#------------------------------------------------------------------------------
# Monitoring
#------------------------------------------------------------------------------
variable "monitoring" {
  description = "CloudWatch dashboards, GuardDuty, Security Hub, and Config monitoring settings"
  type = object({
    dashboard_platform_ops              = string
    dashboard_identity                  = string
    dashboard_dr                        = string
    log_retention_days                  = number
    guardduty_org_detector_enabled      = bool
    securityhub_standards_aws_fsbp      = bool
    securityhub_standards_cis           = bool
    finding_volume_monthly              = number
    config_rule_count                   = number
    config_evaluation_lag_seconds       = number
  })
}

#------------------------------------------------------------------------------
# Networking
#------------------------------------------------------------------------------
variable "networking" {
  description = "Transit Gateway, VPC, NAT Gateway, Direct Connect, and VPC endpoint settings"
  type = object({
    vpc_cidr_network_account     = string
    vpc_cidr_master_pool         = string
    nat_gateway_count            = number
    direct_connect_primary_gbps  = number
    direct_connect_dr_gbps       = number
    macsec_enabled               = bool
    vpn_backup_enabled           = bool
    firewall_inspection_enabled  = bool
    vpc_endpoint_services        = list(string)
  })
}

#------------------------------------------------------------------------------
# Storage
#------------------------------------------------------------------------------
variable "storage" {
  description = "S3 log archive and Terraform state bucket configuration"
  type = object({
    log_archive_object_lock_mode             = string
    log_archive_cloudtrail_volume_gb_monthly = number
    tf_state_versioning_enabled              = bool
  })
}

#------------------------------------------------------------------------------
# Operations
#------------------------------------------------------------------------------
variable "operations" {
  description = "Backup, DR, patching, and compliance operations settings"
  type = object({
    backup_plan_name              = string
    backup_retention_days         = number
    backup_dr_replication_enabled = bool
    dr_rto_hours                  = number
    dr_rpo_hours                  = number
    dr_failover_activation_minutes = number
    patch_baseline_schedule       = string
    platform_availability_target  = number
    change_freeze_pre_review_days = number
    hypercare_duration_weeks      = number
    hypercare_p1_response_hours   = number
  })
}

#------------------------------------------------------------------------------
# Compute (Lambda sizing)
#------------------------------------------------------------------------------
variable "compute" {
  description = "Lambda function memory, timeout, and concurrency configuration"
  type = object({
    lambda_siem_forward_memory_mb        = number
    lambda_siem_forward_timeout_seconds  = number
    lambda_siem_forward_reserved_concurrency  = number
    lambda_itsm_integration_memory_mb    = number
    lambda_itsm_integration_reserved_concurrency = number
    lambda_config_remediation_memory_mb  = number
    lambda_config_remediation_max_concurrency = number
    lambda_aft_pipeline_memory_mb        = number
  })
}
