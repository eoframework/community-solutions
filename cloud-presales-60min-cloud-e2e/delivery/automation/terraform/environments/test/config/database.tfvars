#------------------------------------------------------------------------------
# Database Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-04 19:28:42
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  # DynamoDB billing mode for all three platform tables
  dynamodb_billing_mode = "PAY_PER_REQUEST"
  # KMS key alias for DynamoDB at-rest encryption on all platform tables
  dynamodb_encryption_key_alias = "aws/dynamodb"
  # DynamoDB GlobalQuota table name storing the atomic monthly solution counter
  dynamodb_global_quota_table_name = "amatra-dev-ddb-global-quota"
  # Enable DynamoDB Point-In-Time Recovery on all production and DR tables
  dynamodb_pitr_enabled = false
  # DynamoDB Solutions table name storing generation status and artifact S3 location map
  dynamodb_solutions_table_name = "amatra-dev-ddb-solutions"
  # DynamoDB Users table name storing user profiles and per-user monthly quota counters
  dynamodb_users_table_name = "amatra-dev-ddb-users"
}
