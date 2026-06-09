#------------------------------------------------------------------------------
# Project Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 21:41:31
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aws = {
  # AWS Audit account identifier hosting Security Hub aggregator and GuardDuty org detector
  account_id_audit = "[account-id]"  # TODO: Replace with actual value
  # AWS Log Archive account identifier hosting centralised CloudTrail and Config S3 buckets
  account_id_log_archive = "[account-id]"  # TODO: Replace with actual value
  # AWS Network account identifier hosting Transit Gateway and Network Firewall
  account_id_network = "[account-id]"  # TODO: Replace with actual value
  # AWS Security account identifier hosting IAM Identity Center SSO portal and SAML connector
  account_id_security = "[account-id]"  # TODO: Replace with actual value
  # AWS Control Tower home region; must match solution.region.primary
  control_tower_home_region = "ap-southeast-2"
  # AWS Organizations root organisation ID used by Control Tower and SCP targeting
  organizations_id = "[org-id]"  # TODO: Replace with actual value
}

solution = {
  # Deployment environment identifier used in resource tagging and SCP conditions
  environment = "prod"
  # Solution identifier used for resource naming and tagging across all accounts
  name = "aws-governance-platform"
  # Primary AWS region for all solution resources; DR uses ap-southeast-4
  region_primary = "ap-southeast-2"
}
