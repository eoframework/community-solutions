#------------------------------------------------------------------------------
# Database Module (Tier 2) - DynamoDB catalog-moods + user-history tables
# Calls: aws/dynamodb
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Catalog Mood-Tag Index Table
#------------------------------------------------------------------------------
module "catalog_moods" {
  source = "../aws/dynamodb"

  table_name   = var.catalog_table_name
  billing_mode = var.billing_mode
  hash_key     = "content_id"

  attributes = [
    { name = "content_id", type = "S" },
    { name = "mood_label", type = "S" },
    { name = "tagged_at", type = "S" },
  ]

  global_secondary_indexes = [
    {
      name            = var.catalog_gsi_name
      hash_key        = "mood_label"
      range_key       = "tagged_at"
      projection_type = "ALL"
    }
  ]

  pitr_enabled = var.catalog_pitr_enabled
  common_tags  = var.common_tags
}

#------------------------------------------------------------------------------
# User Listening History Table
#------------------------------------------------------------------------------
module "user_history" {
  source = "../aws/dynamodb"

  table_name   = var.user_history_table_name
  billing_mode = var.billing_mode
  hash_key     = "user_id"
  range_key    = "played_at"

  attributes = [
    { name = "user_id", type = "S" },
    { name = "played_at", type = "S" },
  ]

  ttl_attribute = var.user_history_ttl_attribute
  pitr_enabled  = var.user_history_pitr_enabled
  common_tags   = var.common_tags
}
