#------------------------------------------------------------------------------
# Compute Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 01:56:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  # Amazon API Gateway REST API resource name
  apigw_api_name = "anp-api-prod"
  # API Gateway usage plan burst limit for concurrent request spikes above rate limit
  apigw_burst_limit = 200
  # API Gateway usage plan steady-state rate limit in requests per second
  apigw_rate_limit_rps = 100
  # SQS dead-letter queue name for failed Auto-Tagger S3 event processing
  lambda_autotagger_dlq_name = "anp-autotagger-dlq-prod"
  # Lambda function name for the S3-triggered auto-tagging batch pipeline
  lambda_autotagger_function_name = "anp-autotagger-prod"
  # Maximum Bedrock invocation retry count inside Auto-Tagger Lambda before routing to DLQ
  lambda_autotagger_max_retries = 3
  # Memory allocation in MB for the Auto-Tagger Lambda
  lambda_autotagger_memory_mb = 512
  # Maximum execution duration in seconds for the Auto-Tagger Lambda per S3 event
  lambda_autotagger_timeout_seconds = 60
  # Maximum token count for Bedrock InvokeModel response on classification requests
  lambda_classifier_bedrock_max_tokens = 512
  # Amazon Bedrock foundation model ID used for mood classification inference
  lambda_classifier_bedrock_model_id = "[bedrock-model-id]"  # TODO: Replace with actual value
  # Lambda function name for the POST /classify mood classification endpoint
  lambda_classifier_function_name = "anp-classifier-prod"
  # Memory allocation in MB for the Classifier Lambda; determines proportional CPU
  lambda_classifier_memory_mb = 1024
  # Pre-initialized Lambda instance count for Classifier; 0 disables provisioned concurrency
  lambda_classifier_provisioned_concurrency = 0
  # Lambda runtime environment for the Classifier function
  lambda_classifier_runtime = "python3.12"
  # Maximum execution duration in seconds for the Classifier Lambda
  lambda_classifier_timeout_seconds = 30
  # Lambda function name for the GET /recommend personalized playlist endpoint
  lambda_recommender_function_name = "anp-recommender-prod"
  # Number of recent listening history records fetched per user for recommendation exclusion
  lambda_recommender_history_lookback = 20
  # Memory allocation in MB for the Recommender Lambda
  lambda_recommender_memory_mb = 512
  # Maximum execution duration in seconds for the Recommender Lambda
  lambda_recommender_timeout_seconds = 15
}
