#------------------------------------------------------------------------------
# Compute Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-08 21:29:43
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  # API Gateway backend integration timeout in milliseconds
  apigw_integration_timeout_ms = 29000
  # API Gateway stage name embedded in endpoint URLs
  apigw_stage_name = "prod"
  # ElastiCache Redis node type for playlist and session caching
  elasticache_node_type = "cache.t3.micro"
  # Lambda CPU architecture; arm64 reduces cost by approximately 20 percent
  lambda_architecture = "arm64"
  # Memory for the API Gateway Lambda Authorizer
  lambda_authorizer_memory_mb = 256
  # Timeout for the Lambda Authorizer; kept short to avoid latency on every API call
  lambda_authorizer_timeout_seconds = 5
  # Memory for the Catalog Enrichment Lambda orchestrator
  lambda_enrichment_memory_mb = 512
  # Timeout for the Catalog Enrichment Lambda; Step Functions handles retries
  lambda_enrichment_timeout_seconds = 300
  lambda_feedback_memory_mb = 256  # Memory for the Feedback Capture Lambda
  # Memory for the Playlist Generation Lambda function
  lambda_playlist_memory_mb = 1024
  # Timeout for Playlist Lambda; must stay below API GW 29 s hard limit
  lambda_playlist_timeout_seconds = 29
  # Memory for the Preference Update Lambda that consumes from SQS
  lambda_preference_update_memory_mb = 512
  # OpenSearch node instance type for semantic catalog search
  opensearch_instance_type = "t3.small.search"
  # EBS volume size in GB attached to the OpenSearch node
  opensearch_volume_gb = 20
  # SageMaker endpoint name for audio feature extraction
  sagemaker_audio_endpoint_name = "anp-prod-audio-extractor-endpoint"
  # SageMaker instance type for the audio feature extractor endpoint
  sagemaker_audio_instance_type = "ml.t3.medium"
  # SageMaker endpoint name for NLP emotion/mood/theme classifier
  sagemaker_nlp_endpoint_name = "anp-prod-nlp-classifier-endpoint"
  # SageMaker instance type for the NLP classifier inference endpoint
  sagemaker_nlp_instance_type = "ml.t3.medium"
  # SageMaker instance type for model training and retraining jobs
  sagemaker_training_instance_type = "ml.m5.xlarge"
  # Enable Managed Spot Training for SageMaker training jobs
  sagemaker_training_use_spot = true
}
