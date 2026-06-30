#------------------------------------------------------------------------------
# Application Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-30 01:10:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

application = {
  # Maximum ECS Fargate task count for dashboard and API backend auto-scaling ceiling
  concurrency_max = 4
  # Logging verbosity for all ECS Fargate tasks and Lambda functions
  log_level = "debug"
  # Application identifier used for logging and monitoring across all tiers
  name = "medcore-cds"
  # Application server port for ECS Fargate clinical dashboard and API backend containers
  port = 8080
  # Clinical dashboard session token expiry in hours aligned to clinical shift length
  session_timeout_hours = 8
  # HTTP request timeout in seconds for clinical dashboard API endpoints
  timeout_seconds = 30
  # Current application version; updated on each production deployment
  version = "1.0.0"
}
