#------------------------------------------------------------------------------
# Tier 2 — Database capability module
# Composes: aws/dynamodb (users, solutions, global quota tables)
#------------------------------------------------------------------------------

module "users_table" {
  source       = "../aws/dynamodb"
  table_name   = var.database.users_table_name
  billing_mode = var.database.billing_mode
  hash_key     = "userId"
  pitr_enabled = var.database.pitr_enabled
  attributes = [
    { name = "userId", type = "S" }
  ]
  common_tags = var.common_tags
}

module "solutions_table" {
  source     = "../aws/dynamodb"
  table_name = var.database.solutions_table_name
  billing_mode = var.database.billing_mode
  hash_key   = "solutionId"
  range_key  = "userId"
  pitr_enabled = var.database.pitr_enabled
  attributes = [
    { name = "solutionId", type = "S" },
    { name = "userId",     type = "S" },
    { name = "createdAt",  type = "S" }
  ]
  global_secondary_indexes = [
    {
      name            = "userId-createdAt-index"
      hash_key        = "userId"
      range_key       = "createdAt"
      projection_type = "ALL"
    }
  ]
  common_tags = var.common_tags
}

module "global_quota_table" {
  source       = "../aws/dynamodb"
  table_name   = var.database.global_quota_table_name
  billing_mode = var.database.billing_mode
  hash_key     = "month"
  pitr_enabled = var.database.pitr_enabled
  attributes = [
    { name = "month", type = "S" }
  ]
  common_tags = var.common_tags
}
