#------------------------------------------------------------------------------
# Compute Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-04 19:28:42
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  # Number of Strands agents registered with Bedrock AgentCore Runtime per solution generation
  agentcore_agents_count = 5
  # ECR image reference policy for AgentCore Runtime agent registration
  agentcore_image_tag_policy = "immutable-digest"
  # Maximum concurrent invocations allowed per AgentCore Runtime agent
  agentcore_max_concurrency_per_agent = 10
  # Memory allocation in MB for the Admin Usage Lambda function
  lambda_admin_usage_memory_mb = 256
  # Execution timeout in seconds for the Admin Usage Lambda; covers CloudWatch Metrics API calls
  lambda_admin_usage_timeout_seconds = 15
  # Memory allocation in MB for the Artifact Fetch Lambda function
  lambda_artifact_fetch_memory_mb = 256
  # Execution timeout in seconds for the Artifact Fetch Lambda
  lambda_artifact_fetch_timeout_seconds = 10
  # Reserved concurrency limit for GitHub Integration Lambda to avoid exhausting GitHub PAT rate limits
  lambda_github_integration_concurrency_limit = 20
  # Memory allocation in MB for the GitHub Integration Lambda function
  lambda_github_integration_memory_mb = 512
  # Execution timeout in seconds for the GitHub Integration Lambda; covers multi-file commit round-trips
  lambda_github_integration_timeout_seconds = 60
  # Memory allocation in MB for the Cognito Post-Confirmation Lambda trigger
  lambda_post_confirmation_memory_mb = 256
  # Execution timeout in seconds for the Cognito Post-Confirmation Lambda
  lambda_post_confirmation_timeout_seconds = 15
  # Python runtime version for all Lambda route handler functions
  lambda_runtime = "python3.12"
  # Reserved concurrency limit for the Solution Create Lambda to protect DynamoDB quota table from burst writes
  lambda_solution_create_concurrency_limit = 50
  # Memory allocation in MB for the Solution Create Lambda function
  lambda_solution_create_memory_mb = 512
  # Provisioned Concurrency instances for Solution Create Lambda to eliminate cold-start latency in production
  lambda_solution_create_provisioned_concurrency = 2
  # Execution timeout in seconds for the Solution Create Lambda; covers quota check + AgentCore invocation initiation
  lambda_solution_create_timeout_seconds = 30
  # Memory allocation in MB for the Solution Status Lambda function
  lambda_status_memory_mb = 256
  # Execution timeout in seconds for the Solution Status Lambda
  lambda_status_timeout_seconds = 10
}
