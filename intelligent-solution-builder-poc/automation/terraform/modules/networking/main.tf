###############################################################################
# Tier 2 Solution Module — Networking
# Composes the AWS VPC module for the ISB platform private network.
###############################################################################

module "vpc" {
  source = "../aws/vpc"

  name_prefix          = var.name_prefix
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  nat_gateway_count    = var.nat_gateway_count
  enable_privatelink_endpoints = var.enable_privatelink_endpoints
  common_tags          = var.common_tags
}
