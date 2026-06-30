################################################################################
# Tier 2 — Storage Module
# Composes aws/s3 + aws/rds + aws/elasticache for the full CDS data layer.
################################################################################

# ---------------------------------------------------------------------------
# S3 — Data lake (HL7 event archive + ML artefacts)
# ---------------------------------------------------------------------------
module "s3_datalake" {
  source = "../aws/s3"

  name_prefix         = var.name_prefix
  bucket_name         = var.storage.datalake_bucket_name
  bucket_suffix       = "datalake"
  kms_key_arn         = var.kms_s3_datalake_key_arn
  data_classification = "phi-restricted"
  enable_object_lock  = false

  enable_replication                   = var.storage.cross_region_replication_enabled
  replication_destination_bucket_arn   = var.replication_datalake_bucket_arn
  replication_destination_kms_key_arn  = var.replication_kms_key_arn

  lifecycle_rules = [
    {
      id                     = "archive-to-glacier"
      prefix                 = "archives/"
      transition_days        = 90
      transition_storage_class = "GLACIER"
    }
  ]

  common_tags = var.common_tags
}

# ---------------------------------------------------------------------------
# S3 — HIPAA audit log delivery (7-year WORM, Object Lock Compliance)
# ---------------------------------------------------------------------------
module "s3_audit" {
  source = "../aws/s3"

  name_prefix                 = var.name_prefix
  bucket_name                 = var.storage.audit_bucket_name
  bucket_suffix               = "audit"
  kms_key_arn                 = var.kms_s3_audit_key_arn
  data_classification         = "phi-restricted"
  enable_object_lock          = true
  object_lock_retention_years = var.storage.object_lock_retention_years

  common_tags = var.common_tags
}

# ---------------------------------------------------------------------------
# S3 — SageMaker model artefacts
# ---------------------------------------------------------------------------
module "s3_models" {
  source = "../aws/s3"

  name_prefix         = var.name_prefix
  bucket_name         = var.storage.model_artefacts_bucket_name
  bucket_suffix       = "models"
  kms_key_arn         = var.kms_s3_datalake_key_arn
  data_classification = "sensitive"

  common_tags = var.common_tags
}

# ---------------------------------------------------------------------------
# RDS Aurora PostgreSQL — risk scores, alert history
# ---------------------------------------------------------------------------
module "aurora" {
  source = "../aws/rds"

  name_prefix                = var.name_prefix
  cluster_identifier         = var.storage.aurora_cluster_identifier
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.data_subnet_ids
  allowed_security_group_ids = var.app_security_group_ids
  db_name                    = var.storage.aurora_db_name
  master_username            = var.storage.aurora_master_username
  instance_class             = var.storage.aurora_instance_class
  instance_count             = var.storage.aurora_multi_az_enabled ? 2 : 1
  kms_key_arn                = var.kms_aurora_key_arn
  backup_retention_days      = var.storage.aurora_backup_retention_days
  deletion_protection        = var.storage.aurora_deletion_protection
  skip_final_snapshot        = !var.storage.aurora_deletion_protection

  common_tags = var.common_tags
}

# ---------------------------------------------------------------------------
# ElastiCache Redis — patient context + feature vector cache
# ---------------------------------------------------------------------------
module "elasticache" {
  source = "../aws/elasticache"

  name_prefix                = var.name_prefix
  cluster_id                 = var.storage.elasticache_cluster_id
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.data_subnet_ids
  allowed_security_group_ids = var.app_security_group_ids
  node_type                  = var.storage.elasticache_node_type
  multi_az_enabled           = var.storage.elasticache_multi_az_enabled
  kms_key_arn                = var.kms_elasticache_key_arn
  snapshot_retention_days    = var.storage.elasticache_snapshot_retention_days

  common_tags = var.common_tags
}
