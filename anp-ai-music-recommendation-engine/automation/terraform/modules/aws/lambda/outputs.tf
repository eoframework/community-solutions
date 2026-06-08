output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.main.function_name
}

output "function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.main.arn
}

output "invoke_arn" {
  description = "Lambda function invocation ARN (for API Gateway integration)"
  value       = aws_lambda_function.main.invoke_arn
}

output "qualified_arn" {
  description = "Lambda function qualified ARN (includes version)"
  value       = aws_lambda_function.main.qualified_arn
}

output "log_group_name" {
  description = "CloudWatch log group name for this Lambda function"
  value       = aws_cloudwatch_log_group.lambda.name
}
