output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = module.cognito.user_pool_arn
}

output "user_pool_endpoint" {
  description = "Cognito User Pool endpoint"
  value       = module.cognito.user_pool_endpoint
}

output "app_client_id" {
  description = "Cognito App Client ID"
  value       = module.cognito.app_client_id
}

output "hosted_ui_domain" {
  description = "Cognito hosted UI domain"
  value       = module.cognito.hosted_ui_domain
}
