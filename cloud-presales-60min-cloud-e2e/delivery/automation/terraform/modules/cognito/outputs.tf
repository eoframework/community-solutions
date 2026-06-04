output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito_user_pool.user_pool_id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = module.cognito_user_pool.user_pool_arn
}

output "user_pool_endpoint" {
  description = "Cognito User Pool JWKS endpoint base"
  value       = module.cognito_user_pool.user_pool_endpoint
}

output "app_client_id" {
  description = "Cognito App Client ID"
  value       = module.cognito_user_pool.app_client_id
  sensitive   = true
}

output "post_confirmation_lambda_arn" {
  description = "Post-confirmation Lambda ARN"
  value       = module.lambda_post_confirmation.function_arn
}
