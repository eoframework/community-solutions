################################################################################
# MedCore CDS Platform — Test (QA) Environment
# Region: us-east-1 | Reduced sizing, no WAF/GuardDuty/Macie, single-AZ
################################################################################

locals {
  environment = "test"
  name_prefix = "${var.solution.name}-${local.environment}"

  common_tags = {
    Solution           = var.solution.name
    Environment        = local.environment
    Owner              = "amatra-delivery"
    CostCenter         = "MedCore-ClinicalApps-2026"
    DataClassification = "sensitive"
    Compliance         = "hipaa"
    Phase              = var.solution.phase
    CreatedBy          = "terraform"
    ManagedBy          = "amatra"
    OpportunityNo      = var.solution.opportunity_no
  }

  project = {
    name        = var.solution.name
    environment = local.environment
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#===============================================================================
# FOUNDATION — Core infrastructure
#===============================================================================

# KMS CMKs only — WAF, GuardDuty, Security Hub, Macie all disabled in test
module "security" {
  source = "../../modules/security"

  name_prefix            = local.name_prefix
  multi_region_keys      = false
  enable_cloudtrail      = var.security.config_enabled
  enable_waf             = var.security.waf_enabled
  enable_guardduty       = var.security.guardduty_enabled
  enable_security_hub    = var.security.security_hub_enabled
  enable_macie           = var.security.macie_enabled
  enable_access_analyzer = var.security.iam_access_analyzer_enabled

  common_tags = local.common_tags
}

# VPC + subnets (1 NAT Gateway, PrivateLink enabled)
module "networking" {
  source = "../../modules/networking"

  name_prefix = local.name_prefix
  aws_region  = var.project.primary_region
  kms_key_arn = module.security.kms_s3_audit_key_arn

  network = {
    vpc_cidr            = var.networking.vpc_cidr_primary
    public_subnet_cidrs = [
      var.networking.subnet_cidr_public_az1,
      var.networking.subnet_cidr_public_az2
    ]
    app_subnet_cidrs = [
      var.networking.subnet_cidr_app_az1,
      var.networking.subnet_cidr_app_az2,
      var.networking.subnet_cidr_app_az3
    ]
    data_subnet_cidrs = [
      var.networking.subnet_cidr_data_az1,
      var.networking.subnet_cidr_data_az2
    ]
    availability_zones      = ["${var.project.primary_region}a", "${var.project.primary_region}b", "${var.project.primary_region}c"]
    nat_gateway_count       = var.networking.nat_gateway_count
    enable_privatelink      = var.networking.privatelink_endpoints_enabled
    flow_log_retention_days = var.security.cloudwatch_log_retention_days
  }

  common_tags = local.common_tags

  depends_on = [module.security]
}

#===============================================================================
# CORE SOLUTION — Storage, ingestion, compute, and ML layers
#===============================================================================

module "storage" {
  source = "../../modules/storage"

  name_prefix            = local.name_prefix
  vpc_id                 = module.networking.vpc_id
  data_subnet_ids        = module.networking.data_subnet_ids
  app_security_group_ids = []

  kms_aurora_key_arn      = module.security.kms_aurora_key_arn
  kms_s3_datalake_key_arn = module.security.kms_s3_datalake_key_arn
  kms_s3_audit_key_arn    = module.security.kms_s3_audit_key_arn
  kms_elasticache_key_arn = module.security.kms_elasticache_key_arn

  storage = {
    datalake_bucket_name             = var.storage.datalake_bucket_name
    audit_bucket_name                = var.storage.audit_bucket_name
    model_artefacts_bucket_name      = var.storage.model_artefacts_bucket_name
    object_lock_retention_years      = var.storage.object_lock_retention_years
    cross_region_replication_enabled = var.storage.cross_region_replication_enabled
    aurora_cluster_identifier        = var.database.aurora_cluster_identifier
    aurora_db_name                   = var.database.aurora_db_name
    aurora_master_username           = var.database.aurora_master_username
    aurora_instance_class            = var.database.aurora_instance_type
    aurora_multi_az_enabled          = var.database.aurora_multi_az_enabled
    aurora_backup_retention_days     = var.database.aurora_backup_retention_days
    aurora_deletion_protection       = var.database.aurora_deletion_protection
    elasticache_cluster_id           = var.cache.elasticache_cluster_id
    elasticache_node_type            = var.cache.elasticache_node_type
    elasticache_multi_az_enabled     = var.cache.elasticache_multi_az_enabled
    elasticache_snapshot_retention_days = var.operations.backup_elasticache_retention_days
  }

  common_tags = local.common_tags

  depends_on = [module.networking, module.security]
}

module "ingestion" {
  source = "../../modules/ingestion"

  name_prefix            = local.name_prefix
  vpc_id                 = module.networking.vpc_id
  app_subnet_ids         = module.networking.app_subnet_ids
  app_security_group_ids = []
  kms_key_id             = module.security.kms_s3_datalake_key_arn
  kms_ebs_key_arn        = module.security.kms_ebs_key_arn

  ingestion = {
    kinesis_stream_name      = var.ml.kinesis_stream_name
    kinesis_shard_count      = var.ml.kinesis_shard_count
    kinesis_retention_hours  = var.ml.kinesis_retention_hours
    msk_cluster_name         = var.ml.msk_cluster_name
    msk_broker_count         = var.ml.msk_broker_count
    msk_broker_instance_type = var.ml.msk_broker_instance_type
  }

  common_tags = local.common_tags

  depends_on = [module.networking, module.security]
}

module "compute" {
  source = "../../modules/compute"

  name_prefix       = local.name_prefix
  environment       = local.environment
  aws_region        = var.project.primary_region
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  app_subnet_ids    = module.networking.app_subnet_ids
  certificate_arn   = var.networking.certificate_arn
  kms_key_arn       = module.security.kms_s3_audit_key_arn

  compute = {
    ecs_cluster_name           = var.compute.ecs_cluster_name
    ecs_task_cpu               = var.compute.ecs_task_cpu
    ecs_task_memory_mb         = var.compute.ecs_task_memory_mb
    ecs_scaling_min            = var.compute.ecs_scaling_min
    ecs_scaling_max            = var.compute.ecs_scaling_max
    app_port                   = var.application.port
    log_level                  = var.application.log_level
    log_retention_days         = var.security.cloudwatch_log_retention_days
    enable_deletion_protection = false
    dashboard_container_image  = var.compute.dashboard_container_image
    api_container_image        = var.compute.api_container_image
  }

  common_tags = local.common_tags

  depends_on = [module.networking, module.security]
}

module "ml_platform" {
  source = "../../modules/ml-platform"

  name_prefix         = local.name_prefix
  environment         = local.environment
  models_bucket_arn   = module.storage.models_bucket_arn
  datalake_bucket_arn = module.storage.datalake_bucket_arn
  kms_s3_key_arn      = module.security.kms_s3_datalake_key_arn
  kms_ebs_key_arn     = module.security.kms_ebs_key_arn

  ml = {
    registry_name                     = var.ml.model_registry_name
    bedrock_model_id                  = var.ml.bedrock_model_id
    bedrock_prompt_template_version   = var.ml.bedrock_prompt_template_version
    sepsis_risk_score_alert_threshold = var.ml.sepsis_risk_score_alert_threshold
    feature_completeness_threshold    = var.ml.feature_completeness_threshold
    duplicate_suppression_ttl_seconds = var.operations.alert_duplicate_suppression_minutes * 60
    cloudwatch_log_retention_days     = var.security.cloudwatch_log_retention_days
  }

  common_tags = local.common_tags

  depends_on = [module.storage, module.security]
}

#===============================================================================
# OPERATIONS — Monitoring (minimal for test)
#===============================================================================

module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix     = local.name_prefix
  kms_key_arn     = module.security.kms_s3_audit_key_arn
  audit_bucket_id = module.storage.audit_bucket_id

  monitoring = {
    dashboard_name              = var.monitoring.cloudwatch_dashboard_name
    kinesis_stream_name         = var.ml.kinesis_stream_name
    ecs_cluster_name            = var.compute.ecs_cluster_name
    latency_alarm_threshold_ms  = var.monitoring.cloudwatch_latency_alarm_threshold_ms
    ecs_cpu_alarm_threshold_pct = var.monitoring.cloudwatch_ecs_cpu_alarm_threshold_pct
    alb_5xx_alarm_threshold_pct = var.monitoring.cloudwatch_alb_5xx_alarm_threshold_pct
    enable_config               = var.security.config_enabled
    xray_enabled                = var.monitoring.xray_enabled
  }

  common_tags = local.common_tags

  depends_on = [module.storage, module.compute]
}

#===============================================================================
# INTEGRATIONS — Cross-module wiring
#===============================================================================

# WAF → Dashboard ALB (only if WAF is enabled in test)
resource "aws_wafv2_web_acl_association" "dashboard_alb" {
  count        = var.security.waf_enabled ? 1 : 0
  resource_arn = module.compute.alb_dashboard_arn
  web_acl_arn  = module.security.waf_web_acl_arn

  depends_on = [module.compute, module.security]
}

# Kinesis DLQ alarm
resource "aws_cloudwatch_metric_alarm" "kinesis_dlq_depth" {
  alarm_name          = "${local.name_prefix}-kinesis-dlq-non-empty"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Sum"
  threshold           = var.ml.kinesis_dlq_alarm_threshold
  alarm_description   = "HIGH: Kinesis DLQ has messages in test environment"
  alarm_actions       = [module.monitoring.sns_topic_arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = "${var.ml.kinesis_stream_name}-dlq"
  }

  tags = local.common_tags

  depends_on = [module.ingestion, module.monitoring]
}
