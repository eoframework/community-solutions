#------------------------------------------------------------------------------
# Application Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 21:41:31
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aft = {
  # Maximum time allowed for end-to-end AFT account vending before pipeline fails
  pipeline_account_provisioning_timeout_minutes = 60
  # Require ITSM change-approval before AFT pipeline executes account vending
  pipeline_itsm_approval_required = true
  # Maximum concurrent account vending requests the AFT pipeline processes simultaneously
  pipeline_max_concurrent_requests = 5
}

application = {
  # Total AWS accounts at go-live: Management + Log Archive + Audit + Security + Network + 3 Workload
  accounts_at_golive = 8
  # Logging verbosity level for Lambda functions across the platform
  log_level = "debug"
  # Total platform team and workload account owner users federated via IAM Identity Center
  platform_users = 150
  # Current governance platform release version used in tagging and runbook documentation
  version = "1.0.0"
}
