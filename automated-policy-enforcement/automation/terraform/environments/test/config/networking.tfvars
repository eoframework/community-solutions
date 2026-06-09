#------------------------------------------------------------------------------
# Networking Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 21:41:31
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

networking = {
  # Bandwidth in Gbps for the DR AWS Direct Connect hosted connection in ap-southeast-4
  direct_connect_dr_bandwidth_gbps = 1
  # Enable MACsec encryption on both Direct Connect hosted connections
  direct_connect_macsec_enabled = true
  # Bandwidth in Gbps for the primary AWS Direct Connect hosted connection in ap-southeast-2
  direct_connect_primary_bandwidth_gbps = 1
  # Enable AWS Network Firewall stateful inspection for all east-west and on-premises traffic
  firewall_inspection_enabled = true
  # Number of NAT Gateway instances deployed in the Network Account for outbound patch traffic
  nat_gateway_count = 1
  # AWS Transit Gateway ID in ap-southeast-4 (DR) for failover connectivity
  transit_gateway_dr_id = "[tgw-id]"  # TODO: Replace with actual value
  # AWS Transit Gateway ID in ap-southeast-2 (primary) for hub-spoke routing
  transit_gateway_primary_id = "[tgw-id]"  # TODO: Replace with actual value
  # Master RFC 1918 address pool from which workload account VPC /24s are allocated by AFT
  vpc_cidr_master_pool = "10.0.0.0/16"
  # VPC CIDR block for the Network Account inspection VPC
  vpc_cidr_network_account = "10.0.0.0/24"
  # Comma-separated list of AWS services with interface VPC endpoints in all workload accounts
  vpc_endpoints_enabled_services = ["s3,ssm,ssmmessages,ec2messages,kms,secretsmanager,config,cloudtrail"]
  # Enable Site-to-Site VPN as resilient backup path for management and federation traffic
  vpn_backup_enabled = true
}
