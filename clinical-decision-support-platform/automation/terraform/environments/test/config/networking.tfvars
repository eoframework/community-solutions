#------------------------------------------------------------------------------
# Networking Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-30 01:10:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

networking = {
  # Application Load Balancer ARN or ID for the clinical dashboard and API backend (multi-AZ)
  alb_dashboard_id = "[alb-dashboard-id]"  # TODO: Replace with actual value
  # Application Load Balancer ARN or ID for the Epic FHIR R4 subscription inbound endpoint
  alb_fhir_inbound_id = "[alb-fhir-inbound-id]"  # TODO: Replace with actual value
  # Direct Connect hosted connection bandwidth in Gbps from MedCore Nashville DC to AWS us-east-1
  direct_connect_bandwidth_gbps = 0
  # Number of NAT Gateway instances for outbound AWS control-plane calls
  nat_gateway_count = 1
  # Enable VPC Interface Endpoints (PrivateLink) for all AWS managed service communications
  privatelink_endpoints_enabled = true
  # Private application subnet CIDR for AZ1 hosting ECS Fargate tasks and VPC-attached Lambdas
  subnet_cidr_app_az1 = "10.20.10.0/23"
  # Private application subnet CIDR for AZ2 hosting ECS Fargate tasks and VPC-attached Lambdas
  subnet_cidr_app_az2 = "10.20.12.0/23"
  # Private application subnet CIDR for AZ3 hosting ECS Fargate tasks and VPC-attached Lambdas
  subnet_cidr_app_az3 = "10.20.14.0/23"
  # Private data subnet CIDR for AZ1 hosting RDS Aurora and ElastiCache Redis
  subnet_cidr_data_az1 = "10.20.20.0/24"
  # Private data subnet CIDR for AZ2 hosting RDS Aurora replica and ElastiCache replica
  subnet_cidr_data_az2 = "10.20.21.0/24"
  # Public subnet CIDR for AZ1 (ALB and NAT Gateway only; no application workloads)
  subnet_cidr_public_az1 = "10.20.0.0/24"
  # Public subnet CIDR for AZ2 (ALB and NAT Gateway only; no application workloads)
  subnet_cidr_public_az2 = "10.20.1.0/24"
  # VPC CIDR block for the CDS Platform in the primary region (us-east-1)
  vpc_cidr_primary = "10.20.0.0/16"
  # Enable site-to-site VPN as secondary failover path for Direct Connect
  vpn_enabled = false
}
