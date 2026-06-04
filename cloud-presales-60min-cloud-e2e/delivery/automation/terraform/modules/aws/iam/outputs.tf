output "solution_create_role_arn" {
  description = "Solution Create Lambda execution role ARN"
  value       = aws_iam_role.solution_create.arn
}

output "status_role_arn" {
  description = "Solution Status Lambda execution role ARN"
  value       = aws_iam_role.status.arn
}

output "artifact_fetch_role_arn" {
  description = "Artifact Fetch Lambda execution role ARN"
  value       = aws_iam_role.artifact_fetch.arn
}

output "admin_usage_role_arn" {
  description = "Admin Usage Lambda execution role ARN"
  value       = aws_iam_role.admin_usage.arn
}

output "github_integration_role_arn" {
  description = "GitHub Integration Lambda execution role ARN"
  value       = aws_iam_role.github_integration.arn
}

output "post_confirmation_role_arn" {
  description = "Post-Confirmation Lambda execution role ARN"
  value       = aws_iam_role.post_confirmation.arn
}
