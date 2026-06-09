#------------------------------------------------------------------------------
# Database Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 01:56:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  # DynamoDB billing mode for the catalog mood-tag table
  catalog_moods_billing_mode = "PAY_PER_REQUEST"
  # GSI name on catalog moods table enabling mood-filtered recommendation queries
  catalog_moods_gsi_name = "mood_label-index"
  # Minimum Bedrock confidence score for a mood tag to appear in recommendation results
  catalog_moods_min_confidence_threshold = "0.5"
  # Enable DynamoDB Point-in-Time Recovery on the catalog mood-tag table
  catalog_moods_pitr_enabled = false
  # DynamoDB table name for the catalog mood-tag index
  catalog_moods_table_name = "anp-catalog-moods-dev"
  # DynamoDB billing mode for the user listening history table
  user_history_billing_mode = "PAY_PER_REQUEST"
  # Enable DynamoDB Point-in-Time Recovery on the user history table
  user_history_pitr_enabled = false
  # DynamoDB table name for per-user listening history records
  user_history_table_name = "anp-user-history-dev"
  # DynamoDB TTL attribute name used to auto-expire user history records after retention period
  user_history_ttl_attribute = "ttl"
  # Number of days after which user listening history records are auto-deleted via DynamoDB TTL
  user_history_ttl_days = 90
}
