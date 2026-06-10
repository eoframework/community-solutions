#------------------------------------------------------------------------------
# Project Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-10 02:56:40
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aws = {
  # 12-digit AWS account ID for the target deployment account
  account_id = "[aws-account-id]"  # TODO: Replace with actual value
  # AWS region for all resource provisioning; must match solution.region.primary
  region = "us-west-2"
}

solution = {
  # Deployment environment identifier used in resource naming and IAM policies
  environment = "prod"
  # Solution identifier used for all resource naming and tagging
  name = "amatra-isb"
  # Opportunity identifier for cost tracking and tagging
  opportunity_id = "OPP-2026-001"
  # Primary AWS region for all solution resources; enforces US data residency per SOW
  region_primary = "us-west-2"
  # Current platform version used in Lambda aliases and deployment tracking
  version = "1.0.0"
}
