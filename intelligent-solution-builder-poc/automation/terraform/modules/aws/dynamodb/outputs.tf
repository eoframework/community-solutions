output "table_id" {
  description = "DynamoDB table ID"
  value       = aws_dynamodb_table.main.id
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.main.arn
}

output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.main.name
}

output "table_stream_arn" {
  description = "DynamoDB table stream ARN (empty if streams not enabled)"
  value       = aws_dynamodb_table.main.stream_arn
}
