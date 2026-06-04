#------------------------------------------------------------------------------
# Application Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-04 19:28:42
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

application = {
  # Total number of artifact types produced per solution (5 presales + 6 delivery + 1 Terraform bundle)
  artifact_types_count = 12
  # PyPI package name for the pip-installable CLI distributed to consultants
  cli_package_name = "amatra-cli"
  # Number of CLI subcommands included in the pip package; used as acceptance gate in UAT
  cli_subcommand_count = 14
  # Logging verbosity for all Lambda functions and agent container logs
  log_level = "info"
  # Maximum allowed end-to-end solution generation duration in minutes before timeout
  max_solution_generation_minutes = 60
  # Application identifier used in CloudWatch log groups and structured log fields
  name = "amatra-agentic-platform"
  # Current platform version emitted in Lambda structured logs and CLI --version output
  version = "1.0.0"
}
