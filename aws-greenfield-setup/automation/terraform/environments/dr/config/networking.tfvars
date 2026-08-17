#------------------------------------------------------------------------------
# Networking Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-08-17 00:33:59
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

networking = {
  # ARN of the AWS Network Firewall stateful policy in us-east-1
  firewall_policy_arn_us_east_1 = "[nfw-policy-arn-use2]"  # TODO: Replace with actual value
  # ARN of the AWS Network Firewall stateful policy in us-east-2
  firewall_policy_arn_us_east_2 = "[nfw-policy-arn-use1]"  # TODO: Replace with actual value
  # Network Hub VPC CIDR block in us-east-1; must not be allocated from the spoke IPAM pool
  hub_vpc_us_east_1_cidr = "10.192.0.0/20"
  # Network Hub VPC CIDR block in us-east-2; mirrors hub layout with a different offset
  hub_vpc_us_east_2_cidr = "10.128.0.0/20"
  # IPAM regional sub-pool CIDR for us-east-1; supports up to 256 /20 spoke VPCs
  ipam_pool_us_east_1_cidr = "10.0.0.0/10"
  # IPAM regional sub-pool CIDR for us-east-2; supports up to 256 /20 spoke VPCs
  ipam_pool_us_east_2_cidr = "10.64.0.0/10"
  # VPC IPAM top-level supernet CIDR managed in the Network Hub account
  ipam_supernet_cidr = "10.0.0.0/8"
  # Number of NAT Gateway instances per region; one per AZ in production for HA
  nat_gateway_count_per_region = 2
  # CIDR prefix length auto-allocated from IPAM for each new spoke VPC
  spoke_vpc_cidr_prefix_length = 20
  # Transit Gateway ID in us-east-1; shared to all spoke accounts via RAM
  tgw_id_us_east_1 = "[tgw-id-use1]"  # TODO: Replace with actual value
  # Transit Gateway ID in us-east-2; inter-region peering links it to us-east-1 TGW
  tgw_id_us_east_2 = "[tgw-id-use2]"  # TODO: Replace with actual value
  # Enable VPC Flow Logs on all spoke and hub VPCs delivered to Log Archive S3
  vpc_flow_logs_enabled = true
  # Retention period in days for VPC Flow Logs in the Log Archive S3 bucket before Glacier transition
  vpc_flow_logs_retention_days = 90
  # BGP ASN of the on-premises Customer Gateway; used for dynamic route propagation
  vpn_customer_gateway_asn = "[on-prem-bgp-asn]"  # TODO: Replace with actual value
  # On-premises VPN gateway public IP for the AWS Site-to-Site VPN Customer Gateway
  vpn_customer_gateway_ip = "[on-prem-gateway-ip]"  # TODO: Replace with actual value
}
