#------------------------------------------------------------------------------
# Application Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 16:27:28
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

agentcore = {
  # Number of Strands agents registered in Bedrock AgentCore Runtime
  agent_count = 5
  # AgentCore Runtime resource ID for the Code Generator agent
  code_generator_agent_id = "[agentcore-code-gen-id]"  # TODO: Replace with actual value
  # AgentCore Runtime resource ID for the Delivery Generator agent
  delivery_generator_agent_id = "[agentcore-delivery-gen-id]"  # TODO: Replace with actual value
  # AgentCore Runtime resource ID for the EO Validator agent
  eo_validator_agent_id = "[agentcore-eo-validator-id]"  # TODO: Replace with actual value
  # AgentCore Runtime resource ID for the Input Validator agent
  input_validator_agent_id = "[agentcore-input-validator-id]"  # TODO: Replace with actual value
  # AgentCore Runtime resource ID for the Pre-Sales Generator agent
  presales_generator_agent_id = "[agentcore-presales-gen-id]"  # TODO: Replace with actual value
}

api = {
  gateway_id = "[api-gateway-id]"  # TODO: Replace with actual value  # API Gateway HTTP API v2 identifier
  # Total number of JWT-protected Lambda routes per SOW scope
  route_count = 11
  # API Gateway route-level throttle burst limit (requests)
  throttle_burst_limit = 200
  # API Gateway route-level throttle rate limit (requests/second)
  throttle_rate_limit = 100
}

application = {
  # P95 end-to-end solution generation SLA in minutes
  generation_timeout_minutes = 60
  # Logging verbosity level for all Lambda functions and agents
  log_level = "info"
  # Total artifact types produced per solution run per SOW scope
  max_artifacts_per_solution = 12
  # Application identifier used in logging and monitoring
  name = "amatra-presales-platform"
  # Maximum per-artifact validation retry attempts before P1 escalation
  validation_retry_limit = 3
  version = "1.0.0"  # Current application semantic version
}

bedrock = {
  # Bedrock model ID for primary artifact generation (Claude Sonnet 4.6)
  generation_model_id = "us.anthropic.claude-sonnet-4-5"
  # Maximum output token limit per Bedrock inference call
  max_tokens_per_call = 4096
  # Monthly Bedrock token budget ceiling in millions (combined models)
  monthly_token_budget_millions = 25
  # Bedrock model ID for cost-efficient validation (Claude Haiku 4.5)
  validation_model_id = "us.anthropic.claude-haiku-4-5"
}

cli = {
  # Local file path for JWT credential storage on consultant laptops
  credential_storage_path = "~/.amatra/credentials"
  # PyPI package name for the pip-installable CLI distribution
  package_name = "amatra-cli"
  # Total number of CLI subcommands per SOW scope
  subcommand_count = 14
}
