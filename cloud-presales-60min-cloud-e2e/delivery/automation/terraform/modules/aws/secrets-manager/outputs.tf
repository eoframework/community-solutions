output "github_pat_secret_arn" {
  description = "GitHub PAT Secrets Manager secret ARN"
  value       = aws_secretsmanager_secret.github_pat.arn
}

output "github_pat_secret_name" {
  description = "GitHub PAT Secrets Manager secret name"
  value       = aws_secretsmanager_secret.github_pat.name
}
