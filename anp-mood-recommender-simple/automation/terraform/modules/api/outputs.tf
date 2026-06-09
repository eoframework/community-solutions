#------------------------------------------------------------------------------
# API Module (Tier 2) - Outputs
#------------------------------------------------------------------------------

output "api_id" {
  description = "API Gateway REST API ID"
  value       = module.api_gateway.api_id
}

output "stage_invoke_url" {
  description = "Base invocation URL for the deployed API stage"
  value       = module.api_gateway.stage_invoke_url
}

output "api_key_id" {
  description = "API Key ID for POST /classify"
  value       = module.api_gateway.api_key_id
}
