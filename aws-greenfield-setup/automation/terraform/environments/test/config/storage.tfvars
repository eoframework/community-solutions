#------------------------------------------------------------------------------
# Storage Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-08-17 00:33:59
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  # Primary Log Archive S3 bucket name in the Log Archive account (us-east-1)
  log_archive_bucket_name_primary = "[log-archive-s3-bucket-use1]"  # TODO: Replace with actual value
  # CRR destination S3 bucket name in us-east-2 for log archive cross-region replication
  log_archive_bucket_name_replica = "[log-archive-s3-bucket-use2]"  # TODO: Replace with actual value
  # Days after which Log Archive objects transition from S3 Standard to Glacier Instant Retrieval
  log_archive_glacier_transition_days = 30
  # S3 bucket name for Terraform remote state storage; versioning and MFA delete enabled
  terraform_state_bucket_name = "[tf-state-bucket]"  # TODO: Replace with actual value
  # DynamoDB table name for Terraform state locking to prevent concurrent apply conflicts
  terraform_state_dynamodb_lock_table = "[tf-lock-table]"  # TODO: Replace with actual value
}
