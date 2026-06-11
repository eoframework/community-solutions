output "rest_api_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.main.id
}

output "rest_api_arn" {
  description = "API Gateway REST API ARN"
  value       = aws_api_gateway_rest_api.main.arn
}

output "root_resource_id" {
  description = "API Gateway root resource ID"
  value       = aws_api_gateway_rest_api.main.root_resource_id
}

output "authorizer_id" {
  description = "Cognito authoriser ID"
  value       = aws_api_gateway_authorizer.cognito.id
}

output "log_group_arn" {
  description = "API Gateway access log group ARN"
  value       = aws_cloudwatch_log_group.api_gw.arn
}
