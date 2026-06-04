output "users_table_name" {
  description = "DynamoDB Users table name"
  value       = aws_dynamodb_table.users.name
}

output "users_table_arn" {
  description = "DynamoDB Users table ARN"
  value       = aws_dynamodb_table.users.arn
}

output "solutions_table_name" {
  description = "DynamoDB Solutions table name"
  value       = aws_dynamodb_table.solutions.name
}

output "solutions_table_arn" {
  description = "DynamoDB Solutions table ARN"
  value       = aws_dynamodb_table.solutions.arn
}

output "global_quota_table_name" {
  description = "DynamoDB GlobalQuota table name"
  value       = aws_dynamodb_table.global_quota.name
}

output "global_quota_table_arn" {
  description = "DynamoDB GlobalQuota table ARN"
  value       = aws_dynamodb_table.global_quota.arn
}
