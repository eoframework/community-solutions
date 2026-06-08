#------------------------------------------------------------------------------
# Networking Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-08 21:29:43
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

networking = {
  # Number of NAT Gateway instances for outbound internet from private subnets
  nat_gateway_count = 1
  # Private application subnet in us-east-1a for Lambda ENIs and SageMaker
  private_subnet_app_az1 = "10.10.11.0/24"
  # Private application subnet in us-east-1b for Lambda ENIs and SageMaker
  private_subnet_app_az2 = "10.10.12.0/24"
  # Private data subnet in us-east-1a for OpenSearch and ElastiCache nodes
  private_subnet_data_az1 = "10.10.21.0/24"
  # Private data subnet in us-east-1b for OpenSearch and ElastiCache nodes
  private_subnet_data_az2 = "10.10.22.0/24"
  # Public subnet CIDR in us-east-1a — NAT Gateway only
  public_subnet_az1 = "10.10.1.0/24"
  # Public subnet CIDR in us-east-1b — NAT Gateway only
  public_subnet_az2 = "10.10.2.0/24"
  # VPC CIDR block for the solution VPC in us-east-1
  vpc_cidr = "10.10.0.0/16"
  # VPC Gateway Endpoints keeping S3 and DynamoDB traffic off public internet
  vpc_gateway_endpoints = ["S3,DynamoDB"]
}
