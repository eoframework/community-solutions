#------------------------------------------------------------------------------
# Networking Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 16:27:28
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

networking = {
  # Number of NAT Gateway instances for internet egress
  nat_gateway_count = 1
  # Private subnet CIDR in AZ1 hosting Lambda and AgentCore
  subnet_private_az1_cidr = "10.0.0.0/24"
  # Private subnet CIDR in AZ2 hosting Lambda and AgentCore
  subnet_private_az2_cidr = "10.0.1.0/24"
  # Private subnet CIDR in AZ3 hosting Lambda and AgentCore
  subnet_private_az3_cidr = "10.0.2.0/24"
  subnet_public_cidr = "10.0.100.0/24"  # Public subnet CIDR hosting NAT Gateway
  # VPC CIDR block for the platform in us-west-2
  vpc_cidr = "10.0.0.0/16"
  # Provision VPC interface endpoints for AWS internal services
  vpc_endpoints_enabled = true
}
