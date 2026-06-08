#------------------------------------------------------------------------------
# Tier 2 — Cache: ElastiCache Redis cluster for playlist and session caching
#------------------------------------------------------------------------------

module "elasticache" {
  source = "../aws/elasticache"

  name_prefix           = var.name_prefix
  node_type             = var.node_type
  port                  = var.port
  subnet_ids            = var.subnet_ids
  vpc_id                = var.vpc_id
  app_security_group_id = var.app_security_group_id
  kms_key_arn           = var.user_data_kms_key_arn
  common_tags           = var.common_tags
}
