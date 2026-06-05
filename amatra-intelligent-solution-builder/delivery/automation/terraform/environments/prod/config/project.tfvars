#------------------------------------------------------------------------------
# Project Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 16:27:28
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aws = {
  # AWS account identifier for the fresh us-west-2 footprint
  account_id = "[aws-account-id]"  # TODO: Replace with actual value
}

solution = {
  # S3 artifact retention period before lifecycle expiry
  artifact_retention_days = 365
  environment = "prod"  # Deployment environment identifier
  # Global hard cap on solutions generated per calendar month
  monthly_quota_global = 1000
  # Per-user hard cap on solutions generated per calendar month
  monthly_quota_per_user = 10
  # Solution identifier used for resource naming and tagging
  name = "amatra-presales-platform"
  # Opportunity identifier for cost allocation tagging
  opportunity_id = "OPP-2026-001"
  # Primary AWS region for all solution resources per SOW
  region_primary = "us-west-2"
}
