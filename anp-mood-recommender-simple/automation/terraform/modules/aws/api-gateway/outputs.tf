#------------------------------------------------------------------------------
# AWS API Gateway - Outputs
#------------------------------------------------------------------------------

output "api_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.this.id
}

output "api_arn" {
  description = "API Gateway REST API ARN"
  value       = aws_api_gateway_rest_api.this.arn
}

output "stage_invoke_url" {
  description = "Base URL for the API stage (e.g. https://<id>.execute-api.<region>.amazonaws.com/v1)"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "execution_arn" {
  description = "Execution ARN used for Lambda permission scoping"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "api_key_id" {
  description = "API Key ID"
  value       = aws_api_gateway_api_key.this.id
}
