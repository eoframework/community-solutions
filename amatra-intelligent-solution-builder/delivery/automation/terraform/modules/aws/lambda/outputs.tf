output "lambda_function_arns" {
  description = "Map of Lambda function names to ARNs"
  value = {
    api_handler = aws_lambda_function.api_handler.arn
    quota_reset = aws_lambda_function.quota_reset.arn
  }
}

output "lambda_invoke_arns" {
  description = "Map of Lambda function names to invoke ARNs (for API Gateway)"
  value = {
    api_handler = aws_lambda_function.api_handler.invoke_arn
    quota_reset = aws_lambda_function.quota_reset.invoke_arn
  }
}

output "lambda_function_names" {
  description = "Map of Lambda function names"
  value = {
    api_handler = aws_lambda_function.api_handler.function_name
    quota_reset = aws_lambda_function.quota_reset.function_name
  }
}

output "lambda_exec_role_arn" {
  description = "Lambda execution IAM role ARN"
  value       = aws_iam_role.lambda_exec.arn
}
