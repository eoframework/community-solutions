output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "Lambda function invoke ARN (for API Gateway integration)"
  value       = aws_lambda_function.this.invoke_arn
}

output "alias_arn" {
  description = "Lambda alias ARN"
  value       = aws_lambda_alias.this.arn
}

output "alias_invoke_arn" {
  description = "Lambda alias invoke ARN (for API Gateway integration)"
  value       = aws_lambda_alias.this.invoke_arn
}

output "role_arn" {
  description = "Lambda execution role ARN"
  value       = aws_iam_role.lambda.arn
}

output "role_name" {
  description = "Lambda execution role name"
  value       = aws_iam_role.lambda.name
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.lambda.name
}
