#------------------------------------------------------------------------------
# Database Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-10 02:56:40
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  # DynamoDB capacity billing mode for both tables
  billing_mode = "PAY_PER_REQUEST"
  # SECRET (KMS CMK alias used for DynamoDB at-rest encryption on both tables): inject via Secrets Manager / SSM at deploy time
  encryption_key_alias = "SET_VIA_SECRETS_MANAGER"
  # Enable DynamoDB Point-in-Time Recovery on both tables
  pitr_enabled = true
  # DynamoDB table name for tracking solution job status and artifact S3 keys
  solution_state_table = "AmatraISB-SolutionState-Prod"
  # DynamoDB TTL in days for COMPLETE SolutionState records
  ttl_solution_state_days = 365
  # DynamoDB TTL in days for UsageTracking records
  ttl_usage_tracking_days = 365
  # DynamoDB table name for per-user and global monthly generation usage counters
  usage_tracking_table = "AmatraISB-UsageTracking-Prod"
}
