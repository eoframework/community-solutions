#------------------------------------------------------------------------------
# Project Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-08 21:29:43
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aws = {
  # Dedicated ANP Streaming AWS account identifier
  account_id = "[aws-account-id]"  # TODO: Replace with actual value
  # CDK bootstrap stack name in the target AWS account
  cdk_toolkit_stack_name = "CDKToolkit"
}

solution = {
  # Deployment environment identifier used in all resource names
  environment = "prod"
  # Solution identifier used for resource naming and cost-allocation tagging
  name = "anp-recommendation-engine"
  # Opportunity number for CostCenter tag on all AWS resources
  opportunity_no = "OPP-2026-001"
  # Primary AWS region for all solution resources
  region_primary = "us-east-1"
}
