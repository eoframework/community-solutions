################################################################################
# MedCore CDS Platform — DR (Disaster Recovery) Environment
# Passive standby region: us-west-2 | Mirrors prod sizing | Route 53 failover
################################################################################

locals {
  environment = "dr"
  name_prefix = "${var.solution.name}-${local.environment}"

  common_tags = {
    Solution           = var.solution.name
    Environment        = local.environment
    Owner              = "amatra-delivery"
    CostCenter         = "MedCore-ClinicalApps-2026"
    DataClassification = "phi-restricted"
    Compliance         = "hipaa,soc2,hitech"
    Phase              = var.solution.phase
    Purpose            = "DisasterRecovery"
    Standby            = "true"
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
# FOUNDATION — Core infrastructure (mirrors prod, WAF disabled in passive DR)
#===============================================================================

# KMS CMKs only — WAF/GuardDuty managed at primary (prod)
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

# VPC in DR region (us-west-2)
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

# S3 buckets (DR receives replicated objects from prod) + Aurora + ElastiCache
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

  # Replication disabled in DR — it receives from prod, does not replicate further
  storage = {
    datalake_bucket_name             = var.storage.datalake_bucket_name
    audit_bucket_name                = var.storage.audit_bucket_name
    model_artefacts_bucket_name      = var.storage.model_artefacts_bucket_name
    object_lock_retention_years      = var.storage.object_lock_retention_years
    cross_region_replication_enabled = false
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

# Kinesis + MSK — standby capacity in DR region
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

# ECS Fargate — standby capacity (scaled to minimum in DR until failover)
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
    enable_deletion_protection = true
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
# OPERATIONS — Monitoring (full visibility in DR for failover readiness)
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

# WAF → Dashboard ALB in DR (if WAF enabled for DR)
resource "aws_wafv2_web_acl_association" "dashboard_alb" {
  count        = var.security.waf_enabled ? 1 : 0
  resource_arn = module.compute.alb_dashboard_arn
  web_acl_arn  = module.security.waf_web_acl_arn

  depends_on = [module.compute, module.security]
}

# Aurora replica lag alarm (DR readiness monitoring)
resource "aws_cloudwatch_metric_alarm" "aurora_replica_lag" {
  alarm_name          = "${local.name_prefix}-aurora-replica-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 10
  metric_name         = "AuroraReplicaLag"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 5000
  alarm_description   = "HIGH: DR Aurora replica lag > 5 seconds — DR readiness at risk"
  alarm_actions       = [module.monitoring.sns_topic_arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = var.database.aurora_cluster_identifier
  }

  tags = local.common_tags

  depends_on = [module.storage, module.monitoring]
}
