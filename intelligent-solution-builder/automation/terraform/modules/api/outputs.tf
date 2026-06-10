output "rest_api_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.this.id
}

output "rest_api_arn" {
  description = "API Gateway REST API ARN"
  value       = aws_api_gateway_rest_api.this.arn
}

output "execution_arn" {
  description = "API Gateway execution ARN (for Lambda permissions)"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "stage_arn" {
  description = "API Gateway stage ARN (for WAF WebACL association)"
  value       = aws_api_gateway_stage.this.arn
}

output "invoke_url" {
  description = "API Gateway stage invoke URL"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "stage_name" {
  description = "API Gateway stage name"
  value       = aws_api_gateway_stage.this.stage_name
}
