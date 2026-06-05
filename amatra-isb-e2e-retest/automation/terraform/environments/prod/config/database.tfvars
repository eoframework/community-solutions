#------------------------------------------------------------------------------
# Database Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 19:11:53
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  # DynamoDB immutable audit log table capturing all API calls per SOC 2 CC7 requirements
  audit_events_table_name = "eofw-prd-tbl-audit-events"
  # TTL-based retention for audit_events records; expires items automatically without manual deletion
  audit_events_ttl_days = 90
  # DynamoDB billing mode for all four tables; On-Demand auto-scales to any throughput
  billing_mode = "PAY_PER_REQUEST"
  # Days of API inactivity before the scheduled Lambda suspends the Cognito account per SOC 2 CC6.2
  inactive_user_suspension_days = 90
  # Enable DynamoDB Point-In-Time Recovery on all four tables; required for 4-hour RTO target
  pitr_enabled = true
  # Maximum total solutions across all users per calendar month per SOW scope parameter
  quota_global_monthly = 1000
  # Maximum solutions per Amatra consultant per calendar month per SOW scope parameter
  quota_per_user_monthly = 10
  # DynamoDB table for per-user and global atomic quota counters (PK: user_id or GLOBAL)
  quotas_table_name = "eofw-prd-tbl-quotas"
  # DynamoDB table storing solution state / artifact statuses / per-phase token usage (PK: solution_id)
  solutions_table_name = "eofw-prd-tbl-solutions"
  # DynamoDB table storing Cognito user profiles written by post-confirmation trigger Lambda
  users_table_name = "eofw-prd-tbl-users"
}
