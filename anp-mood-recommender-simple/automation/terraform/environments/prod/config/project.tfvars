#------------------------------------------------------------------------------
# Project Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 01:56:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aws = {
  # AWS account identifier for the ANP Streaming deployment account
  account_id = "[aws-account-id]"  # TODO: Replace with actual value
  # AWS region code used in SDK configuration and ARN construction
  region = "us-east-1"
}

solution = {
  # Deployment environment identifier used in resource names and tags
  environment = "prod"
  # Solution identifier used in resource naming and tagging
  name = "anp-streaming-ai"
  # nClouds opportunity identifier for cost allocation and resource tagging
  opportunity_id = "OPP-2025-001"
  # Primary AWS region for all solution resources
  region_primary = "us-east-1"
}
