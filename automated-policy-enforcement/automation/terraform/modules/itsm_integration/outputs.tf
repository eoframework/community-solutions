output "lambda_arn" {
  description = "ARN of the ITSM approval polling Lambda function"
  value       = aws_lambda_function.itsm_approval.arn
}

output "lambda_name" {
  description = "Name of the ITSM approval Lambda function"
  value       = aws_lambda_function.itsm_approval.function_name
}
