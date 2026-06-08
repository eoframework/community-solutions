#------------------------------------------------------------------------------
# Application Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-08 21:29:43
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

application = {
  # API Gateway usage-plan requests per second per API key
  api_rate_limit_rps = 100
  # API path version prefix used in all REST endpoint URLs
  api_version = "v1"
  # Minimum interaction events before Personalize replaces mood-only cold-start fallback
  cold_start_threshold = 10
  # Logging verbosity for all Lambda functions
  log_level = "info"
  # Application identifier for structured logs and CloudWatch dashboards
  name = "anp-streaming-ai"
  # Default track count returned by the playlist generation endpoint
  playlist_count_default = 20
  # Semantic version of the deployed application
  version = "1.0.0"
}
