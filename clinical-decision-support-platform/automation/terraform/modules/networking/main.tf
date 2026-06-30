################################################################################
# Tier 2 — Networking Module
# Composes aws/vpc to create the full multi-tier VPC for the CDS Platform.
################################################################################

module "vpc" {
  source = "../aws/vpc"

  name_prefix         = var.name_prefix
  vpc_cidr            = var.network.vpc_cidr
  public_subnet_cidrs = var.network.public_subnet_cidrs
  app_subnet_cidrs    = var.network.app_subnet_cidrs
  data_subnet_cidrs   = var.network.data_subnet_cidrs
  availability_zones  = var.network.availability_zones
  nat_gateway_count   = var.network.nat_gateway_count
  enable_privatelink  = var.network.enable_privatelink
  aws_region          = var.aws_region
  kms_key_arn         = var.kms_key_arn

  flow_log_retention_days = var.network.flow_log_retention_days

  common_tags = var.common_tags
}
