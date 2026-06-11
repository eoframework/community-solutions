###############################################################################
# Tier 2 Solution Module — Storage
# Composes S3 and DynamoDB Tier 1 modules for all ISB data stores.
###############################################################################

#--------------------------------------
# Artifacts S3 bucket
#--------------------------------------
module "s3_artifacts" {
  source     = "../aws/s3"
  bucket_name = var.artifacts_bucket_name
  kms_key_arn = var.kms_artifacts_key_arn
  versioning_enabled    = var.s3_versioning_enabled
  enable_lifecycle_rules = true
  intelligent_tiering_days = var.s3_intelligent_tiering_days
  glacier_transition_days  = var.s3_glacier_transition_days
  enable_replication               = var.enable_s3_replication
  replication_role_arn             = var.s3_replication_role_arn
  replication_destination_bucket_arn = var.dr_replication_bucket_arn
  replication_destination_kms_key_arn = var.dr_replication_kms_key_arn
  force_destroy = var.force_destroy
  common_tags   = var.common_tags
}

#--------------------------------------
# Solution State DynamoDB table
#--------------------------------------
module "dynamodb_solution_state" {
  source     = "../aws/dynamodb"
  table_name = var.solution_state_table_name
  hash_key   = "solution_id"
  attributes = [
    { name = "solution_id", type = "S" },
    { name = "user_id", type = "S" },
    { name = "created_at", type = "S" }
  ]
  global_secondary_indexes = [
    {
      name            = "user_id-created_at-index"
      hash_key        = "user_id"
      range_key       = "created_at"
      projection_type = "ALL"
    }
  ]
  kms_key_arn                 = var.kms_database_key_arn
  pitr_enabled                = var.pitr_enabled
  ttl_attribute               = "expires_at"
  deletion_protection_enabled = var.deletion_protection_enabled
  common_tags                 = var.common_tags
}

#--------------------------------------
# Usage Tracking DynamoDB table
#--------------------------------------
module "dynamodb_usage_tracking" {
  source     = "../aws/dynamodb"
  table_name = var.usage_tracking_table_name
  hash_key   = "user_id"
  range_key  = "month_key"
  attributes = [
    { name = "user_id", type = "S" },
    { name = "month_key", type = "S" }
  ]
  global_secondary_indexes = []
  kms_key_arn                 = var.kms_database_key_arn
  pitr_enabled                = var.pitr_enabled
  ttl_attribute               = ""
  deletion_protection_enabled = var.deletion_protection_enabled
  common_tags                 = var.common_tags
}

#--------------------------------------
# Audit Records DynamoDB table
#--------------------------------------
module "dynamodb_audit" {
  source     = "../aws/dynamodb"
  table_name = var.audit_table_name
  hash_key   = "record_id"
  attributes = [
    { name = "record_id", type = "S" }
  ]
  global_secondary_indexes    = []
  kms_key_arn                 = var.kms_database_key_arn
  pitr_enabled                = false
  ttl_attribute               = "expires_at"
  deletion_protection_enabled = var.deletion_protection_enabled
  common_tags                 = var.common_tags
}

#--------------------------------------
# Terraform State S3 bucket
#--------------------------------------
module "s3_terraform_state" {
  source     = "../aws/s3"
  bucket_name = var.terraform_state_bucket_name
  kms_key_arn = var.kms_artifacts_key_arn
  versioning_enabled     = true
  enable_lifecycle_rules = false
  enable_replication     = false
  force_destroy          = false
  common_tags            = var.common_tags
}

#--------------------------------------
# Terraform State Lock DynamoDB table
#--------------------------------------
module "dynamodb_terraform_lock" {
  source     = "../aws/dynamodb"
  table_name = var.terraform_lock_table_name
  hash_key   = "LockID"
  attributes = [
    { name = "LockID", type = "S" }
  ]
  global_secondary_indexes    = []
  kms_key_arn                 = var.kms_database_key_arn
  pitr_enabled                = false
  ttl_attribute               = ""
  deletion_protection_enabled = false
  common_tags                 = var.common_tags
}
