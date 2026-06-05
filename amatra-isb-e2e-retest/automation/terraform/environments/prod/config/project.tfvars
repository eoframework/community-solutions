#------------------------------------------------------------------------------
# Project Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 19:11:53
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

solution = {
  # AWS account ID hosting the us-west-2 platform footprint
  account_id = "[aws-account-id]"  # TODO: Replace with actual value
  # Cost center tag applied to all AWS resources for billing attribution per SOC 2 CC9.1
  cost_center = "AMATRA-PRESALES-2026"
  # Hard go-live deadline (end of April 2026) for executive demonstration to Sarah Lin (CRO)
  deadline = "2026-04-30"
  # Deployment environment identifier used in resource naming pattern eofw-{env}-*
  environment = "production"
  # Solution identifier used for resource naming and tagging across all environments
  name = "aws-agentic-presales"
  # Primary AWS deployment region; isolated from PREDICTif us-east-1 workloads per SOW
  region_primary = "us-west-2"
  # Current platform release version tracked in GitHub and used for CLI pip package versioning
  version = "1.0.0"
}
