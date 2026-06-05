#------------------------------------------------------------------------------
# Compute Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 19:11:53
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  # Full ECR URI including tag for the eof-tools Docker image baked with ~30 Python converter modules
  ecr_agent_image_uri = "[ecr-agent-image-uri]"  # TODO: Replace with actual value
  # ECR repository name for the eof-tools agent container image
  ecr_repository_name = "eofw-dev-ecr-agent-image"
  # Memory for the 5 agent orchestration trigger Lambdas running eof-tools container image
  lambda_agent_trigger_memory_mb = 1024
  # Maximum Lambda timeout applied to agent triggers to accommodate eof-tools conversion
  lambda_agent_trigger_timeout_seconds = 900
  # Memory allocation for non-generation API route handler Lambda functions (10 functions)
  lambda_api_handler_memory_mb = 256
  # Timeout for synchronous API route handlers; generation initiator uses separate config
  lambda_api_handler_timeout_seconds = 30
  # Lambda function CPU architecture; arm64 provides better price-performance for Python workloads
  lambda_architecture = "arm64"
  # Memory for the Cognito post-confirmation trigger Lambda that writes DynamoDB user profiles
  lambda_cognito_trigger_memory_mb = 256
  # Timeout for the Cognito post-confirmation trigger; must complete before Cognito times out
  lambda_cognito_trigger_timeout_seconds = 10
  # Memory for the Solution Generation Initiator Lambda that triggers the five-agent graph
  lambda_generation_initiator_memory_mb = 512
  # Timeout for the Solution Generation Initiator Lambda; returns 202 Accepted immediately
  lambda_generation_initiator_timeout_seconds = 60
  # Memory for the GitHub push Lambda that commits artifacts to the configured repository
  lambda_github_push_memory_mb = 256
  # Timeout for GitHub push Lambda; accounts for Secrets Manager retrieval and GitHub API call
  lambda_github_push_timeout_seconds = 60
  # Provisioned concurrency for agent triggers; set to 0 at launch; evaluate after Phase 3 load test
  lambda_provisioned_concurrency_agent_triggers = 0
  # Python runtime version for all 17 Lambda functions
  lambda_runtime = "python3.12"
  # Total Lambda functions: 11 API routes + 5 agent triggers + 1 Cognito post-confirmation
  lambda_total_function_count = 17
  # AWS X-Ray tracing mode for all 17 Lambda functions; enables distributed service maps
  lambda_xray_tracing = "Active"
}
