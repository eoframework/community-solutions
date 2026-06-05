#------------------------------------------------------------------------------
# Database Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 16:27:28
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dynamodb = {
  # DynamoDB billing mode for all platform tables
  billing_mode = "PAY_PER_REQUEST"
  # Enable DynamoDB Point-in-Time Recovery on all tables
  pitr_enabled = true
  # DynamoDB TTL for solution state records in days
  solution_state_ttl_days = 90
  # DynamoDB table name for global 1000/month quota pool counter
  table_quota_global = "amatra-prod-quota-global"
  # DynamoDB table name for per-solution execution state and artifact status
  table_solution_state = "amatra-prod-solution-state"
  # DynamoDB table name for user profiles and per-user quota counters
  table_user_profiles = "amatra-prod-user-profiles"
}
