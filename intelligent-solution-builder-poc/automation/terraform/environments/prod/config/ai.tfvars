#------------------------------------------------------------------------------
# Ai Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-11 15:01:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

bedrock = {
  # Maximum output tokens requested per Bedrock InvokeModel call per artifact type
  max_tokens_per_artifact = 4096
  # Amazon Bedrock model ID for Claude 3 Sonnet used by the Bedrock Orchestration Lambda
  model_id = "anthropic.claude-3-sonnet-20240229-v1:0"
  # Configured Bedrock token consumption quota per month (input + output) matching the Large tier cost model
  monthly_token_quota = 90000000
  # Maximum times the Output Validation Lambda retries a failed Bedrock generation before marking the job as VALIDATION_FAILED
  output_validation_max_retries = 3
  # S3 key prefix under the artifacts bucket where versioned Bedrock prompt templates are stored
  prompt_templates_s3_prefix = "prompts/"
  # AWS region for Bedrock InvokeModel API calls; must match solution region for PrivateLink routing
  region = "us-west-2"
}
