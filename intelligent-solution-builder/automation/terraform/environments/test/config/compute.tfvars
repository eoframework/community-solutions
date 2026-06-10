#------------------------------------------------------------------------------
# Compute Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-10 02:56:40
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  # Memory allocation in MB for the brief-submission API Handler Lambda (isb-api-submit)
  lambda_api_submit_memory_mb = 512
  # Provisioned concurrency units for isb-api-submit to eliminate cold-start on latency-sensitive path
  lambda_api_submit_provisioned_concurrency = 0
  # Timeout in seconds for the brief-submission API Handler Lambda
  lambda_api_submit_timeout_seconds = 30
  # Memory allocation in MB for the Artifact Processor / QA scoring Lambda
  lambda_artifact_processor_memory_mb = 512
  # Timeout in seconds for the Artifact Processor / QA scoring Lambda
  lambda_artifact_processor_timeout_seconds = 300
  # Memory allocation in MB for the Bedrock Invoker Lambda for Claude 3 Haiku (lightweight artifact types)
  lambda_bedrock_haiku_memory_mb = 512
  # Timeout in seconds for the Bedrock Invoker Lambda for Claude 3 Haiku
  lambda_bedrock_haiku_timeout_seconds = 600
  # Memory allocation in MB for the Bedrock Invoker Lambda for Claude 3 Sonnet (complex artifact types)
  lambda_bedrock_sonnet_memory_mb = 1024
  # Timeout in seconds for the Bedrock Invoker Lambda for Claude 3 Sonnet
  lambda_bedrock_sonnet_timeout_seconds = 900
  # Total reserved Lambda concurrency across all platform functions to prevent account-level starvation
  lambda_reserved_concurrency_total = 100
  # Python runtime version for all Lambda functions
  lambda_runtime = "python3.12"
}
