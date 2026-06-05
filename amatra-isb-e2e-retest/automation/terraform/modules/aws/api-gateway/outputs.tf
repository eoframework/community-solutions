output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.main.id
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_apigatewayv2_api.main.execution_arn
}

output "authorizer_id" {
  description = "Cognito JWT authoriser ID"
  value       = aws_apigatewayv2_authorizer.cognito.id
}

output "stage_id" {
  description = "Default stage ID"
  value       = aws_apigatewayv2_stage.main.id
}
