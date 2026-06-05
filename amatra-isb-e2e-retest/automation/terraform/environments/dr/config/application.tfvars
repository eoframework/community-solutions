#------------------------------------------------------------------------------
# Application Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 19:11:53
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

application = {
  # Total Strands agents registered in Bedrock AgentCore Runtime per SOW scope
  agent_count = 5
  # Total HTTP API v2 Lambda routes per SOW specification
  api_route_count = 11
  # Total EO Framework artifact types: 5 presales + 6 delivery + 1 Terraform automation bundle
  artifact_types_count = 12
  # Pip-installable Python package name for the 14-subcommand consultant-facing CLI
  cli_package_name = "eoframework-cli"
  # Total CLI subcommands including auth / generate / status / admin per SOW specification
  cli_subcommand_count = 14
  # End-to-end 12-artifact solution bundle generation time limit; SLA target from SOW
  generation_timeout_minutes = 60
  # Logging verbosity for all 17 Lambda functions; debug enabled in dev for agent tracing
  log_level = "info"
  # Maximum automatic retries per artifact in the EO Validator validation loop
  max_retries_per_artifact = 3
  # Application identifier used in CloudWatch log groups and X-Ray service maps
  name = "eoframework"
  # HTTPS port enforced on API Gateway HTTP API v2; HTTP requests rejected
  port = 443
  # Synchronous API route Lambda timeout in seconds; async generation routes use separate config
  timeout_seconds = 30
}
