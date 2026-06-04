output "api_id" {
  description = "API Gateway HTTP API v2 ID"
  value       = aws_apigatewayv2_api.main.id
}

output "api_endpoint" {
  description = "API Gateway HTTP API v2 default endpoint URL"
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "stage_arn" {
  description = "API Gateway stage ARN (used for WAF WebACL association)"
  value       = "${aws_apigatewayv2_stage.main.execution_arn}"
}

output "execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_apigatewayv2_api.main.execution_arn
}
