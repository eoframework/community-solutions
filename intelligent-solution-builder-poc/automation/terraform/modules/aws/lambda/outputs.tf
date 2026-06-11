output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.main.function_name
}

output "function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.main.arn
}

output "alias_arn" {
  description = "Lambda live alias ARN"
  value       = aws_lambda_alias.live.arn
}

output "invoke_arn" {
  description = "Lambda function invoke ARN (for API Gateway integration)"
  value       = aws_lambda_function.main.invoke_arn
}

output "alias_invoke_arn" {
  description = "Lambda alias invoke ARN"
  value       = aws_lambda_alias.live.invoke_arn
}

output "execution_role_arn" {
  description = "Lambda execution IAM role ARN"
  value       = aws_iam_role.lambda.arn
}

output "execution_role_name" {
  description = "Lambda execution IAM role name"
  value       = aws_iam_role.lambda.name
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.main.name
}
