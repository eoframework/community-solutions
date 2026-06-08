#------------------------------------------------------------------------------
# Integration Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-08 21:29:43
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

integration = {
  # Maximum token count for Bedrock inference requests
  bedrock_max_tokens = 512
  # Bedrock foundation model ID for lyric and transcript emotion enrichment
  bedrock_model_id = "amazon.titan-text-express-v1"
  # EventBridge custom event bus name for catalog upload events
  eventbridge_catalog_bus_name = "anp-prod-catalog"
  # Firebase REST API base URL for read-only catalog metadata access
  firebase_api_url = "https://anp-streaming-default-rtdb.firebaseio.com"
  # Timeout for Firebase REST API calls in milliseconds
  firebase_timeout_ms = 30000
  # Amazon Personalize campaign ARN serving real-time playlist recommendations
  personalize_campaign_arn = "[personalize-campaign-arn]"  # TODO: Replace with actual value
  # Amazon Personalize dataset group ARN for the preference-learning model
  personalize_dataset_group_arn = "[personalize-dataset-group-arn]"  # TODO: Replace with actual value
  # Amazon Personalize event tracker ID for interaction event ingestion
  personalize_event_tracker_id = "[personalize-event-tracker-id]"  # TODO: Replace with actual value
  # SQS Dead Letter Queue URL for feedback events failing after 3 retries
  sqs_feedback_dlq_url = "[sqs-feedback-dlq-url]"  # TODO: Replace with actual value
  # SQS message retention in seconds for the feedback capture queue
  sqs_feedback_queue_retention_seconds = 345600
  # SQS standard queue URL for feedback capture events
  sqs_feedback_queue_url = "[sqs-feedback-queue-url]"  # TODO: Replace with actual value
  # SQS redrive policy: attempts before routing to DLQ
  sqs_max_receive_count = 3
  # Step Functions state machine ARN for the catalog enrichment workflow
  stepfunctions_enrichment_arn = "[enrichment-state-machine-arn]"  # TODO: Replace with actual value
}
