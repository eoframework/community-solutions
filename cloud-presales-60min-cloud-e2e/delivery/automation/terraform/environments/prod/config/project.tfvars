#------------------------------------------------------------------------------
# Project Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-04 19:28:42
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aws = {
  # AWS account identifier for the us-west-2 greenfield deployment
  account_id = "[aws-account-id]"  # TODO: Replace with actual value
  # AWS deployment region passed to Terraform provider and all SDK clients
  region = "us-west-2"
}

solution = {
  # Deployment environment identifier used in all resource naming patterns
  environment = "prod"
  # Solution identifier used for resource naming and tagging across all environments
  name = "amatra-agentic-orchestration-platform"
  # Opportunity reference number used in cost-centre tagging and billing attribution
  opportunity_id = "OPP-2026-001"
  # Primary AWS region for all platform resources per SOW scope
  region_primary = "us-west-2"
  # Resource name prefix following naming convention amatra-{env} applied to all AWS resources
  resource_name_prefix = "amatra-prod"
}
