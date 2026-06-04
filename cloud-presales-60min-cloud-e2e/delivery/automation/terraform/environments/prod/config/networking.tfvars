#------------------------------------------------------------------------------
# Networking Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-04 19:28:42
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

networking = {
  # Custom domain name for API Gateway endpoint; TLS certificate managed by ACM
  api_gateway_custom_domain = "api.amatra.predictif.com"
  # API Gateway HTTP API v2 stage ARN used in WAF WebACL association
  api_gateway_stage_arn = "[api-gateway-stage-arn]"  # TODO: Replace with actual value
  # API Gateway HTTP API v2 stage name used in the invocation URL path
  api_gateway_stage_name = "prod"
  # API Gateway stage-level burst concurrency throttle limit
  api_gateway_throttle_burst_limit = 10000
  # API Gateway stage-level steady-state requests-per-second throttle limit
  api_gateway_throttle_rate_limit = 5000
  # Minimum TLS version enforced on the API Gateway custom domain
  api_gateway_tls_minimum_version = "TLS_1_2"
}
