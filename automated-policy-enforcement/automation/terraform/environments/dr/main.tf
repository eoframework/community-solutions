#------------------------------------------------------------------------------
# AWS Cloud Governance Platform — DR Environment
# ap-southeast-4 (ap-southeast-4 primary for DR) | Warm standby
# Mirrors production configuration; RTO < 4h / RPO < 1h
#------------------------------------------------------------------------------

locals {
  environment  = "dr"
  name_prefix  = "${var.solution.name}-${local.environment}"

  common_tags = {
    Solution     = var.solution.name
    Environment  = local.environment
    Version      = var.solution.version
    Region       = var.solution.region
    ManagedBy    = "terraform"
    OwnerTeam    = var.ownership.owner_team
    CostCentre   = var.ownership.cost_centre
    ProjectCode  = var.ownership.project_code
    Compliance   = "iso27001"
    Project      = "aws-governance-platform"
    Purpose      = "DisasterRecovery"
    Standby      = "true"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#===============================================================================
# FOUNDATION — Core infrastructure for DR region (ap-southeast-4)
#===============================================================================

# KMS — separate CMK in DR region for independent key management
module "kms" {
  source = "../../modules/aws/kms"

  name_prefix      = local.name_prefix
  environment      = local.environment
  rotation_enabled = var.security.kms_rotation_enabled
  common_tags      = local.common_tags
}

# Networking — DR region inspection VPC and VPC endpoints
module "networking" {
  source = "../../modules/aws/vpc"

  name_prefix              = local.name_prefix
  environment              = local.environment
  vpc_cidr                 = var.networking.vpc_cidr_network_account
  vpc_endpoint_services    = var.networking.vpc_endpoint_services
  nat_gateway_count        = var.networking.nat_gateway_count
  firewall_inspection_enabled = var.networking.firewall_inspection_enabled
  common_tags              = local.common_tags

  depends_on = [module.kms]
}

# Security — IAM roles, permission sets mirrored in DR region
module "security" {
  source = "../../modules/security"

  name_prefix                      = local.name_prefix
  environment                      = local.environment
  kms_key_arn                      = module.kms.key_arn
  kms_key_id                       = module.kms.key_id
  deny_console_access_policy_name  = var.scp.deny_console_access_policy_name
  region_lock_allowed_regions      = var.scp.region_lock_allowed_regions
  encryption_enforce_policy_name   = var.scp.encryption_enforce_policy_name
  console_access_blocked_in_prod   = var.security.console_access_blocked_in_prod
  session_timeout_minutes          = var.security.session_timeout_minutes
  breakglass_session_minutes       = var.identity.breakglass_session_minutes
  permission_set_developer         = var.identity.permission_set_developer
  permission_set_operator          = var.identity.permission_set_operator
  permission_set_security_viewer   = var.identity.permission_set_security_viewer
  credentials_rotation_days        = var.security.credentials_rotation_days
  common_tags                      = local.common_tags

  depends_on = [module.kms, module.networking]
}

#===============================================================================
# CORE SOLUTION — DR region governance components (warm standby)
#===============================================================================

# Storage — DR S3 log archive (CRR destination from primary), DR Terraform state
module "storage" {
  source = "../../modules/storage"

  name_prefix                   = local.name_prefix
  environment                   = local.environment
  kms_key_arn                   = module.kms.key_arn
  log_archive_object_lock_mode  = var.storage.log_archive_object_lock_mode
  log_retention_years           = var.security.cloudtrail_log_retention_years
  tf_state_versioning_enabled   = var.storage.tf_state_versioning_enabled
  dr_region                     = var.solution.dr_region
  common_tags                   = local.common_tags

  depends_on = [module.kms, module.security]
}

# Database — DynamoDB tables in DR region (warm standby, restored from AWS Backup)
module "database" {
  source = "../../modules/aws/dynamodb"

  name_prefix              = local.name_prefix
  environment              = local.environment
  kms_key_arn              = module.kms.key_arn
  aft_table_name           = var.database.aft_workflow_table_name
  aft_billing_mode         = var.database.aft_workflow_billing_mode
  aft_backup_enabled       = var.database.aft_workflow_backup_enabled
  tf_lock_table_name       = var.database.tf_state_lock_table
  common_tags              = local.common_tags

  depends_on = [module.kms]
}

# AFT Pipeline — DR instance (activated on failover)
module "aft_pipeline" {
  source = "../../modules/aft"

  name_prefix                          = local.name_prefix
  environment                          = local.environment
  itsm_approval_required               = var.application.itsm_approval_required
  max_concurrent_requests              = var.application.max_concurrent_requests
  account_provisioning_timeout_minutes = var.application.account_provisioning_timeout_minutes
  aft_workflow_table_name              = var.database.aft_workflow_table_name
  lambda_memory_mb                     = var.compute.lambda_aft_pipeline_memory_mb
  log_level                            = var.application.log_level
  kms_key_arn                          = module.kms.key_arn
  tf_state_bucket_name                 = module.storage.tf_state_bucket_name
  tf_lock_table_name                   = var.database.tf_state_lock_table
  common_tags                          = local.common_tags

  depends_on = [module.database, module.storage, module.security]
}

# SIEM Integration — DR SIEM forwarding pipeline
module "siem_integration" {
  source = "../../modules/siem_integration"

  name_prefix                  = local.name_prefix
  environment                  = local.environment
  kms_key_arn                  = module.kms.key_arn
  lambda_memory_mb             = var.compute.lambda_siem_forward_memory_mb
  lambda_timeout_seconds       = var.compute.lambda_siem_forward_timeout_seconds
  reserved_concurrency         = var.compute.lambda_siem_forward_reserved_concurrency
  finding_severity_threshold   = var.integration_siem.finding_severity_threshold
  dlq_name                     = var.integration_siem.dlq_name
  dlq_alarm_threshold          = var.integration_siem.dlq_alarm_threshold
  delivery_sla_minutes         = var.integration_siem.delivery_sla_minutes
  log_level                    = var.application.log_level
  log_retention_days           = var.monitoring.log_retention_days
  common_tags                  = local.common_tags

  depends_on = [module.kms, module.security]
}

# ITSM Integration — DR ITSM polling Lambda
module "itsm_integration" {
  source = "../../modules/itsm_integration"

  name_prefix                     = local.name_prefix
  environment                     = local.environment
  kms_key_arn                     = module.kms.key_arn
  lambda_memory_mb                = var.compute.lambda_itsm_integration_memory_mb
  reserved_concurrency            = var.compute.lambda_itsm_integration_reserved_concurrency
  approval_poll_interval_seconds  = var.integration_itsm.approval_poll_interval_seconds
  change_freeze_scp_condition     = var.integration_itsm.change_freeze_scp_condition
  log_level                       = var.application.log_level
  log_retention_days              = var.monitoring.log_retention_days
  common_tags                     = local.common_tags

  depends_on = [module.kms, module.security]
}

# Config Remediation — DR auto-remediation Lambda
module "config_remediation" {
  source = "../../modules/config_remediation"

  name_prefix          = local.name_prefix
  environment          = local.environment
  kms_key_arn          = module.kms.key_arn
  lambda_memory_mb     = var.compute.lambda_config_remediation_memory_mb
  max_concurrency      = var.compute.lambda_config_remediation_max_concurrency
  log_level            = var.application.log_level
  log_retention_days   = var.monitoring.log_retention_days
  common_tags          = local.common_tags

  depends_on = [module.kms, module.security]
}

#===============================================================================
# OPERATIONS — Monitoring and DR vault (receives backups from primary)
#===============================================================================

# Monitoring — CloudWatch dashboards for DR region replication health
module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix                  = local.name_prefix
  environment                  = local.environment
  dashboard_platform_ops       = var.monitoring.dashboard_platform_ops
  dashboard_identity           = var.monitoring.dashboard_identity
  dashboard_dr                 = var.monitoring.dashboard_dr
  log_retention_days           = var.monitoring.log_retention_days
  dlq_name                     = var.integration_siem.dlq_name
  dlq_alarm_threshold          = var.integration_siem.dlq_alarm_threshold
  config_rule_count            = var.monitoring.config_rule_count
  finding_volume_monthly       = var.monitoring.finding_volume_monthly
  kms_key_arn                  = module.kms.key_arn
  siem_dlq_url                 = module.siem_integration.dlq_url
  aft_pipeline_name            = module.aft_pipeline.pipeline_name
  common_tags                  = local.common_tags

  depends_on = [module.siem_integration, module.aft_pipeline]
}

# Best Practices — AWS Backup vault (receives CRR from prod), Config in DR region
# GuardDuty and WAF are disabled in DR (managed at primary)
module "best_practices" {
  source = "../../modules/best_practices"

  name_prefix                     = local.name_prefix
  environment                     = local.environment
  kms_key_arn                     = module.kms.key_arn
  backup_plan_name                = var.operations.backup_plan_name
  backup_retention_days           = var.operations.backup_retention_days
  backup_dr_replication_enabled   = var.operations.backup_dr_replication_enabled
  dr_region                       = var.solution.dr_region
  guardduty_enabled               = false
  securityhub_fsbp_enabled        = var.monitoring.securityhub_standards_aws_fsbp
  securityhub_cis_enabled         = var.monitoring.securityhub_standards_cis
  config_rule_count               = var.monitoring.config_rule_count
  log_retention_days              = var.monitoring.log_retention_days
  sns_topic_arn                   = module.monitoring.sns_topic_arn
  common_tags                     = local.common_tags

  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  depends_on = [module.monitoring, module.storage]
}

# DR vault — receives backup copies from primary region
module "dr" {
  source = "../../modules/dr"

  name_prefix                     = local.name_prefix
  environment                     = local.environment
  dr_region                       = var.solution.dr_region
  rto_hours                       = var.operations.dr_rto_hours
  rpo_hours                       = var.operations.dr_rpo_hours
  failover_activation_minutes     = var.operations.dr_failover_activation_minutes
  log_archive_bucket_name         = module.storage.log_archive_bucket_name
  kms_key_arn                     = module.kms.key_arn
  backup_plan_name                = var.operations.backup_plan_name
  backup_retention_days           = var.operations.backup_retention_days
  sns_topic_arn                   = module.monitoring.sns_topic_arn
  common_tags                     = local.common_tags

  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  depends_on = [module.storage, module.monitoring, module.best_practices]
}

#===============================================================================
# INTEGRATIONS — Cross-module wiring (avoids circular dependencies)
#===============================================================================

# CloudWatch alarm: SIEM DLQ depth in DR region
resource "aws_cloudwatch_metric_alarm" "siem_dlq_depth" {
  alarm_name          = "${local.name_prefix}-siem-dlq-depth"
  alarm_description   = "P1: SIEM forwarding DLQ has messages — DR delivery failure"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Sum"
  threshold           = var.integration_siem.dlq_alarm_threshold
  treat_missing_data  = "notBreaching"
  alarm_actions       = [module.monitoring.sns_topic_arn]
  ok_actions          = [module.monitoring.sns_topic_arn]
  dimensions = {
    QueueName = var.integration_siem.dlq_name
  }
  tags = local.common_tags

  depends_on = [module.monitoring, module.siem_integration]
}

# CloudWatch alarm: AFT pipeline failure in DR region
resource "aws_cloudwatch_metric_alarm" "aft_pipeline_failure" {
  alarm_name          = "${local.name_prefix}-aft-pipeline-failure"
  alarm_description   = "P1: AFT account vending pipeline has failed (DR region)"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "FailedPipelineExecutions"
  namespace           = "AWS/CodePipeline"
  period              = 120
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [module.monitoring.sns_topic_arn]
  dimensions = {
    PipelineName = module.aft_pipeline.pipeline_name
  }
  tags = local.common_tags

  depends_on = [module.monitoring, module.aft_pipeline]
}
