output "table_user_profiles_name" {
  description = "User profiles DynamoDB table name"
  value       = aws_dynamodb_table.user_profiles.name
}

output "table_user_profiles_arn" {
  description = "User profiles DynamoDB table ARN"
  value       = aws_dynamodb_table.user_profiles.arn
}

output "table_solution_state_name" {
  description = "Solution state DynamoDB table name"
  value       = aws_dynamodb_table.solution_state.name
}

output "table_solution_state_arn" {
  description = "Solution state DynamoDB table ARN"
  value       = aws_dynamodb_table.solution_state.arn
}

output "table_quota_global_name" {
  description = "Global quota DynamoDB table name"
  value       = aws_dynamodb_table.quota_global.name
}

output "table_quota_global_arn" {
  description = "Global quota DynamoDB table ARN"
  value       = aws_dynamodb_table.quota_global.arn
}
