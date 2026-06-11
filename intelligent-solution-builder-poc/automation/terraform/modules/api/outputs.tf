output "rest_api_id" {
  description = "API Gateway REST API ID"
  value       = module.api_gateway.rest_api_id
}

output "rest_api_arn" {
  description = "API Gateway REST API ARN"
  value       = module.api_gateway.rest_api_arn
}

output "root_resource_id" {
  description = "API Gateway root resource ID"
  value       = module.api_gateway.root_resource_id
}

output "authorizer_id" {
  description = "Cognito authoriser ID"
  value       = module.api_gateway.authorizer_id
}
