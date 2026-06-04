output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "Cognito User Pool endpoint (JWKS base URL)"
  value       = aws_cognito_user_pool.main.endpoint
}

output "app_client_id" {
  description = "Cognito App Client ID"
  value       = aws_cognito_user_pool_client.cli.id
  sensitive   = true
}

output "consultants_group_name" {
  description = "Consultants Cognito group name"
  value       = aws_cognito_user_group.consultants.name
}

output "admins_group_name" {
  description = "Admins Cognito group name"
  value       = aws_cognito_user_group.admins.name
}
