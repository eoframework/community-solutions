#------------------------------------------------------------------------------
# Project Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-08-17 00:33:59
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aws = {
  # AWS account ID for the Audit/Security Tooling account (GuardDuty and Security Hub delegated admin)
  account_id_audit = "[audit-account-id]"  # TODO: Replace with actual value
  # AWS account ID for the centralised Log Archive account
  account_id_log_archive = "[log-archive-account-id]"  # TODO: Replace with actual value
  # AWS Management account ID hosting Control Tower and AWS Organizations
  account_id_management = "[management-account-id]"  # TODO: Replace with actual value
  # AWS account ID for the Network Hub account hosting TGW and Network Firewall
  account_id_network_hub = "[network-hub-account-id]"  # TODO: Replace with actual value
  # AWS account ID for the Shared Services account hosting centralised CloudWatch dashboards
  account_id_shared_services = "[shared-services-account-id]"  # TODO: Replace with actual value
  # AWS Organizations organisation ID used in SCPs and RCP data perimeter policies
  organizations_id = "[org-id]"  # TODO: Replace with actual value
  # Root ID of the AWS Organizations hierarchy for SCP and tag policy attachment
  organizations_root_id = "[org-root-id]"  # TODO: Replace with actual value
}

controltower = {
  # Comma-separated list of AWS regions governed by Control Tower
  governed_regions = ["us-east-1,us-east-2"]
  # AWS Control Tower landing zone manifest version deployed
  landing_zone_version = "3.3"
}

ou = {
  # OU ID for the Infrastructure OU hosting Network Hub and Shared Services accounts
  infrastructure_id = "[ou-infrastructure-id]"  # TODO: Replace with actual value
  # OU ID for the Sandbox OU; region restriction and root-deny SCPs remain active
  sandbox_id = "[ou-sandbox-id]"  # TODO: Replace with actual value
  # OU ID for the Security OU hosting Log Archive and Audit accounts
  security_id = "[ou-security-id]"  # TODO: Replace with actual value
  # OU ID for the Suspended OU; deny-all SCP applied to isolated decommissioned accounts
  suspended_id = "[ou-suspended-id]"  # TODO: Replace with actual value
  # OU ID for the Workloads-NonProd OU with relaxed (but enforced) guardrails
  workloads_nonprod_id = "[ou-workloads-nonprod-id]"  # TODO: Replace with actual value
  # OU ID for the Workloads-Prod OU; maximum SCP enforcement applied here
  workloads_prod_id = "[ou-workloads-prod-id]"  # TODO: Replace with actual value
}

solution = {
  # Deployment environment identifier applied to all tagged resources
  environment = "prod"
  # Solution identifier used for resource naming and tagging across all accounts
  name = "aws-landing-zone"
  # Primary AWS region for all Control Tower management-plane and hub resources
  region_primary = "us-east-2"
  # Secondary AWS region governed by Control Tower for DR and multi-region coverage
  region_secondary = "us-east-1"
  # Current solution version used in IaC state labels and runbook references
  version = "1.0.0"
}
