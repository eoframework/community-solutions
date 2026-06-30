#------------------------------------------------------------------------------
# Project Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-30 01:10:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aws = {
  # AWS Organizations OU under which the CDS account is provisioned
  organization_ou = "Clinical Applications OU"
}

solution = {
  # Dedicated AWS account ID under MedCore Clinical Applications OU
  account_id = "[aws-account-id]"  # TODO: Replace with actual value
  # Deployment environment identifier used in all resource names and tags
  environment = "prod"
  # Solution identifier used for resource naming and tagging across all environments
  name = "medcore-cds"
  # Amatra opportunity number for cost allocation and billing reference
  opportunity_no = "OPP-2026-0047"
  # Current active delivery phase; updated at each phase go-live milestone
  phase = "phase1"
  # Passive disaster recovery AWS region for CDS Platform
  region_dr = "us-west-2"
  # Primary AWS region for all active CDS Platform resources
  region_primary = "us-east-1"
}
