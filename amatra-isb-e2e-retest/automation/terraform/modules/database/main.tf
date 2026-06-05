#------------------------------------------------------------------------------
# Database Module - Tier 2 Solution Module
# Composes DynamoDB tables: users, solutions, quotas, audit_events
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Users Table - Cognito user profiles
#------------------------------------------------------------------------------
module "users_table" {
  source = "../aws/dynamodb"

  table_name  = var.database.users_table_name
  billing_mode = var.database.billing_mode
  hash_key    = "user_id"
  range_key   = ""

  attributes = [
    { name = "user_id", type = "S" }
  ]

  pitr_enabled                = var.database.pitr_enabled
  deletion_protection_enabled = var.deletion_protection_enabled

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# Solutions Table - Solution state, artifact statuses, token usage
#------------------------------------------------------------------------------
module "solutions_table" {
  source = "../aws/dynamodb"

  table_name   = var.database.solutions_table_name
  billing_mode = var.database.billing_mode
  hash_key     = "solution_id"
  range_key    = "user_id"

  attributes = [
    { name = "solution_id", type = "S" },
    { name = "user_id",     type = "S" }
  ]

  pitr_enabled                = var.database.pitr_enabled
  deletion_protection_enabled = var.deletion_protection_enabled

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# Quotas Table - Atomic per-user and global quota counters
#------------------------------------------------------------------------------
module "quotas_table" {
  source = "../aws/dynamodb"

  table_name   = var.database.quotas_table_name
  billing_mode = var.database.billing_mode
  hash_key     = "user_id"
  range_key    = "month_key"

  attributes = [
    { name = "user_id",   type = "S" },
    { name = "month_key", type = "S" }
  ]

  pitr_enabled                = var.database.pitr_enabled
  deletion_protection_enabled = var.deletion_protection_enabled

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# Audit Events Table - Immutable audit log with TTL
#------------------------------------------------------------------------------
module "audit_events_table" {
  source = "../aws/dynamodb"

  table_name   = var.database.audit_events_table_name
  billing_mode = var.database.billing_mode
  hash_key     = "event_id"
  range_key    = "timestamp"

  attributes = [
    { name = "event_id",  type = "S" },
    { name = "timestamp", type = "S" }
  ]

  pitr_enabled                = var.database.pitr_enabled
  ttl_attribute               = "ttl"
  deletion_protection_enabled = var.deletion_protection_enabled

  common_tags = var.common_tags
}
