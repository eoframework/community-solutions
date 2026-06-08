#------------------------------------------------------------------------------
# Tier 2 — Database: DynamoDB tables for content catalog, user profiles,
# interaction events, and mood taxonomy reference data
#------------------------------------------------------------------------------

module "content_catalog" {
  source = "../aws/dynamodb"

  table_name        = var.content_catalog_table
  billing_mode      = var.billing_mode
  pitr_enabled      = var.pitr_enabled
  kms_key_arn       = var.catalog_kms_key_arn
  hash_key          = "item_id"
  hash_key_type     = "S"
  name_prefix       = var.name_prefix
  common_tags       = var.common_tags
}

module "user_profiles" {
  source = "../aws/dynamodb"

  table_name        = var.user_profile_table
  billing_mode      = var.billing_mode
  pitr_enabled      = var.pitr_enabled
  kms_key_arn       = var.user_data_kms_key_arn
  hash_key          = "user_id"
  hash_key_type     = "S"
  name_prefix       = var.name_prefix
  common_tags       = var.common_tags
}

module "interaction_events" {
  source = "../aws/dynamodb"

  table_name        = var.interaction_events_table
  billing_mode      = var.billing_mode
  pitr_enabled      = var.pitr_enabled
  kms_key_arn       = var.user_data_kms_key_arn
  hash_key          = "event_id"
  hash_key_type     = "S"
  range_key         = "user_id"
  range_key_type    = "S"
  ttl_attribute     = "ttl"
  name_prefix       = var.name_prefix
  common_tags       = var.common_tags
}

module "mood_taxonomy" {
  source = "../aws/dynamodb"

  table_name        = var.mood_taxonomy_table
  billing_mode      = var.billing_mode
  pitr_enabled      = var.pitr_enabled
  kms_key_arn       = var.catalog_kms_key_arn
  hash_key          = "label_id"
  hash_key_type     = "S"
  name_prefix       = var.name_prefix
  common_tags       = var.common_tags
}
