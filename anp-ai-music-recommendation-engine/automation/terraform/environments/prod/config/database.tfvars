#------------------------------------------------------------------------------
# Database Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-08 21:29:43
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  # DynamoDB billing mode; on-demand handles variable ingest bursts
  billing_mode = "PAY_PER_REQUEST"
  # DynamoDB table for enriched catalog items with emotion/mood attribute scores
  content_catalog_table = "anp-prod-content-catalog"
  # DynamoDB table for play/skip/like/dislike feedback events; primary retraining input
  interaction_events_table = "anp-prod-interaction-events"
  # Retention period in days for InteractionEvents records
  interaction_retention_days = 730
  # DynamoDB reference table for canonical mood taxonomy label set
  mood_taxonomy_table = "anp-prod-mood-taxonomy"
  # Enable DynamoDB Point-in-Time Recovery on all tables
  pitr_enabled = true
  # DynamoDB table for user preference vectors and mood history
  user_profile_table = "anp-prod-user-profiles"
}
