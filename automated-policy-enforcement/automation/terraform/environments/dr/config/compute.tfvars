#------------------------------------------------------------------------------
# Compute Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 21:41:31
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  # Memory allocation in MB for AFT account vending Lambda functions
  lambda_aft_pipeline_memory_mb = 3008
  # Maximum concurrency for Config auto-remediation Lambda to control remediation blast radius
  lambda_config_remediation_max_concurrency = 20
  # Memory allocation in MB for the Config auto-remediation Lambda function
  lambda_config_remediation_memory_mb = 512
  # Memory allocation in MB for the ITSM change-approval integration Lambda function
  lambda_itsm_integration_memory_mb = 512
  # Reserved concurrency for ITSM integration Lambda to prevent API rate limit exhaustion
  lambda_itsm_integration_reserved_concurrency = 5
  # Memory allocation in MB for the SIEM forwarding Lambda function
  lambda_siem_forward_memory_mb = 1024
  # Reserved concurrency for SIEM forwarding Lambda to prevent throttling on peak finding volumes
  lambda_siem_forward_reserved_concurrency = 10
  # Timeout in seconds for the SIEM forwarding Lambda function
  lambda_siem_forward_timeout_seconds = 30
}
