output "api_gateway_url" {
  description = "API Gateway HTTP API invoke URL"
  value       = module.api_gateway.invoke_url
}

output "api_gateway_stage_arn" {
  description = "API Gateway stage ARN (for WAF association)"
  value       = module.api_gateway.stage_arn
}

output "api_gateway_id" {
  description = "API Gateway HTTP API ID"
  value       = module.api_gateway.api_id
}

output "solution_create_function_name" {
  description = "Solution Create Lambda function name"
  value       = module.lambda_solution_create.function_name
}

output "solution_create_function_arn" {
  description = "Solution Create Lambda function ARN"
  value       = module.lambda_solution_create.function_arn
}

output "solution_status_function_name" {
  description = "Solution Status Lambda function name"
  value       = module.lambda_solution_status.function_name
}

output "artifact_fetch_function_name" {
  description = "Artifact Fetch Lambda function name"
  value       = module.lambda_artifact_fetch.function_name
}

output "admin_usage_function_name" {
  description = "Admin Usage Lambda function name"
  value       = module.lambda_admin_usage.function_name
}

output "github_integration_function_name" {
  description = "GitHub Integration Lambda function name"
  value       = module.lambda_github_integration.function_name
}

output "github_integration_function_arn" {
  description = "GitHub Integration Lambda function ARN"
  value       = module.lambda_github_integration.function_arn
}
