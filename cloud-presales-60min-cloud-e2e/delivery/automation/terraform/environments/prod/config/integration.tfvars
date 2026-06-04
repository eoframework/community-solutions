#------------------------------------------------------------------------------
# Integration Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-04 19:28:42
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

integration = {
  # Bedrock model ID for Claude Sonnet 4.6 used by Pre-Sales and Delivery Generator agents
  bedrock_generation_model_id = "anthropic.claude-sonnet-4-6"
  # Initial backoff delay in milliseconds before first Bedrock retry on throttling error
  bedrock_generation_retry_initial_delay_ms = 1000
  # Maximum number of Bedrock generation + EO Validator retry cycles per artifact before flagging for human review
  bedrock_max_retries_per_artifact = 3
  # Target maximum combined Bedrock model spend (Sonnet + Haiku) per solution in USD
  bedrock_target_cost_per_solution_usd = "5.00"
  # Bedrock model ID for Claude Haiku 4.5 used by EO Validator Agent for cost-efficient quality checks
  bedrock_validation_model_id = "anthropic.claude-haiku-4-5"
  # Target branch for all artifact commits in the fixed GitHub repository
  github_branch = "main"
  # Maximum number of retry attempts for GitHub commit API calls before routing to CloudWatch DLQ
  github_commit_retry_count = 3
  # Fixed public GitHub repository URL for artifact commit pipeline per SOW scope
  github_repository_url = "https://github.com/predictif-solutions/amatra-artifacts"
}
