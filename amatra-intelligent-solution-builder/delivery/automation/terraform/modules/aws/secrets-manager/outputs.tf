output "github_pat_secret_arn" {
  description = "Secrets Manager ARN for the GitHub PAT"
  value       = aws_secretsmanager_secret.github_pat.arn
}

output "github_pat_secret_name" {
  description = "Secrets Manager secret name for the GitHub PAT"
  value       = aws_secretsmanager_secret.github_pat.name
}

output "cognito_secret_arn" {
  description = "Secrets Manager ARN for the Cognito App Client secret"
  value       = aws_secretsmanager_secret.cognito_secret.arn
}

output "cognito_secret_name" {
  description = "Secrets Manager secret name for the Cognito App Client secret"
  value       = aws_secretsmanager_secret.cognito_secret.name
}
