################################################################################
# Tier 2 — Ingestion Module
# Composes aws/kinesis + aws/msk for the real-time clinical event pipeline.
################################################################################

module "kinesis" {
  source = "../aws/kinesis"

  stream_name     = var.ingestion.kinesis_stream_name
  shard_count     = var.ingestion.kinesis_shard_count
  retention_hours = var.ingestion.kinesis_retention_hours
  kms_key_id      = var.kms_key_id

  common_tags = var.common_tags
}

module "msk" {
  source = "../aws/msk"

  name_prefix                = var.name_prefix
  cluster_name               = var.ingestion.msk_cluster_name
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.app_subnet_ids
  allowed_security_group_ids = var.app_security_group_ids
  broker_count               = var.ingestion.msk_broker_count
  broker_instance_type       = var.ingestion.msk_broker_instance_type
  broker_volume_size_gb      = 200
  kms_key_arn                = var.kms_ebs_key_arn

  common_tags = var.common_tags
}
