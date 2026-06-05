output "function_arn" {
  description = "Lambda function ARN"
  value       = var.package_type == "Image" ? aws_lambda_function.image[0].arn : aws_lambda_function.zip[0].arn
}

output "function_name" {
  description = "Lambda function name"
  value       = var.package_type == "Image" ? aws_lambda_function.image[0].function_name : aws_lambda_function.zip[0].function_name
}

output "invoke_arn" {
  description = "Lambda invoke ARN (for API Gateway)"
  value       = var.package_type == "Image" ? aws_lambda_function.image[0].invoke_arn : aws_lambda_function.zip[0].invoke_arn
}

output "role_arn" {
  description = "Lambda execution role ARN"
  value       = aws_iam_role.main.arn
}

output "role_name" {
  description = "Lambda execution role name"
  value       = aws_iam_role.main.name
}

output "security_group_id" {
  description = "Lambda security group ID"
  value       = aws_security_group.lambda.id
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.main.name
}
