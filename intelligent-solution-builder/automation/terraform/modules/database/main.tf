#------------------------------------------------------------------------------
# Tier 2 — Database Module
# Composes: aws/dynamodb — SolutionState and UsageTracking tables
# SOC 2 A1 / GDPR data minimisation — state and usage governance layer
#------------------------------------------------------------------------------

module "solution_state_table" {
  source = "../aws/dynamodb"

  table_name          = var.solution_state_table_name
  billing_mode        = var.billing_mode
  hash_key            = "solution_id"
  range_key           = "artifact_id"
  kms_key_arn         = var.kms_dynamodb_key_arn
  pitr_enabled        = var.pitr_enabled
  deletion_protection = var.pitr_enabled
  ttl_attribute       = "expires_at"

  attributes = [
    { name = "solution_id", type = "S" },
    { name = "artifact_id", type = "S" },
    { name = "user_id",     type = "S" },
    { name = "created_at",  type = "S" },
    { name = "status",      type = "S" },
  ]

  global_secondary_indexes = [
    {
      name            = "UserSolutionsIndex"
      hash_key        = "user_id"
      range_key       = "created_at"
      projection_type = "ALL"
    },
    {
      name            = "StatusIndex"
      hash_key        = "status"
      range_key       = "created_at"
      projection_type = "ALL"
    }
  ]

  common_tags = merge(var.common_tags, {
    TablePurpose = "SolutionStateTracking"
  })
}

module "usage_tracking_table" {
  source = "../aws/dynamodb"

  table_name          = var.usage_tracking_table_name
  billing_mode        = var.billing_mode
  hash_key            = "user_id"
  range_key           = "year_month"
  kms_key_arn         = var.kms_dynamodb_key_arn
  pitr_enabled        = var.pitr_enabled
  deletion_protection = var.pitr_enabled
  ttl_attribute       = "expires_at"

  attributes = [
    { name = "user_id",    type = "S" },
    { name = "year_month", type = "S" },
  ]

  global_secondary_indexes = []

  common_tags = merge(var.common_tags, {
    TablePurpose = "UsageLimitTracking"
  })
}
