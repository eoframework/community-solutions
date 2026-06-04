output "solution_create_function_arn" {
  description = "Solution Create Lambda function ARN"
  value       = aws_lambda_function.solution_create.arn
}

output "solution_create_function_name" {
  description = "Solution Create Lambda function name"
  value       = aws_lambda_function.solution_create.function_name
}

output "solution_create_alias_arn" {
  description = "Solution Create Lambda live alias ARN"
  value       = aws_lambda_alias.solution_create_live.arn
}

output "status_function_arn" {
  description = "Status Lambda function ARN"
  value       = aws_lambda_function.status.arn
}

output "status_function_name" {
  description = "Status Lambda function name"
  value       = aws_lambda_function.status.function_name
}

output "artifact_fetch_function_arn" {
  description = "Artifact Fetch Lambda function ARN"
  value       = aws_lambda_function.artifact_fetch.arn
}

output "artifact_fetch_function_name" {
  description = "Artifact Fetch Lambda function name"
  value       = aws_lambda_function.artifact_fetch.function_name
}

output "admin_usage_function_arn" {
  description = "Admin Usage Lambda function ARN"
  value       = aws_lambda_function.admin_usage.arn
}

output "admin_usage_function_name" {
  description = "Admin Usage Lambda function name"
  value       = aws_lambda_function.admin_usage.function_name
}

output "github_integration_function_arn" {
  description = "GitHub Integration Lambda function ARN"
  value       = aws_lambda_function.github_integration.arn
}

output "github_integration_function_name" {
  description = "GitHub Integration Lambda function name"
  value       = aws_lambda_function.github_integration.function_name
}

output "post_confirmation_function_arn" {
  description = "Post-Confirmation Lambda function ARN"
  value       = aws_lambda_function.post_confirmation.arn
}

output "post_confirmation_function_name" {
  description = "Post-Confirmation Lambda function name"
  value       = aws_lambda_function.post_confirmation.function_name
}
