#------------------------------------------------------------------------------
# Networking Module - Tier 2 Solution Module
# Composes aws/vpc for the EO Framework platform network topology
#------------------------------------------------------------------------------

module "vpc" {
  source = "../aws/vpc"

  name_prefix           = var.name_prefix
  vpc_cidr              = var.networking.vpc_cidr
  public_subnet_cidrs   = var.networking.public_subnet_cidrs
  private_subnet_cidrs  = var.networking.private_subnet_cidrs
  database_subnet_cidrs = var.networking.database_subnet_cidrs
  availability_zones    = var.networking.availability_zones
  nat_gateway_count     = var.networking.nat_gateway_count
  region                = var.region

  enable_s3_endpoint              = var.networking.vpc_endpoint_s3
  enable_dynamodb_endpoint        = var.networking.vpc_endpoint_dynamodb
  enable_secretsmanager_endpoint  = var.networking.vpc_endpoint_secrets_manager
  enable_bedrock_runtime_endpoint = var.networking.vpc_endpoint_bedrock_runtime
  enable_ecr_endpoints            = true
  enable_cloudwatch_logs_endpoint = true

  common_tags = var.common_tags
}
