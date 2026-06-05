output "api_id" {
  description = "API Gateway HTTP API ID"
  value       = aws_apigatewayv2_api.main.id
}

output "api_endpoint" {
  description = "API Gateway HTTP API invoke URL"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "api_arn" {
  description = "API Gateway HTTP API ARN"
  value       = aws_apigatewayv2_api.main.arn
}

output "stage_id" {
  description = "API Gateway default stage ID"
  value       = aws_apigatewayv2_stage.default.id
}
