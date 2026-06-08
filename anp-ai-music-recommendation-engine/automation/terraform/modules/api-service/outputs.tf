output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_name" {
  description = "API Gateway REST API name"
  value       = aws_api_gateway_rest_api.main.name
}

output "api_gateway_endpoint" {
  description = "API Gateway base URL"
  value       = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.apigw_stage_name}"
}

output "api_gateway_stage_arn" {
  description = "ARN of the deployed API Gateway stage"
  value       = "arn:aws:apigateway:${data.aws_region.current.name}::/restapis/${aws_api_gateway_rest_api.main.id}/stages/${aws_api_gateway_stage.main.stage_name}"
}

output "api_gateway_execution_arn" {
  description = "Execution ARN for the API Gateway REST API"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "lambda_execution_role_arn" {
  description = "IAM execution role ARN for all Lambda functions"
  value       = aws_iam_role.lambda_execution.arn
}

output "playlist_lambda_arn" {
  description = "ARN of the Playlist Generation Lambda"
  value       = module.playlist_lambda.function_arn
}

output "enrichment_lambda_arn" {
  description = "ARN of the Catalog Enrichment Lambda"
  value       = module.enrichment_lambda.function_arn
}

output "authorizer_lambda_arn" {
  description = "ARN of the API Gateway Lambda Authorizer"
  value       = module.authorizer_lambda.function_arn
}

output "feedback_lambda_arn" {
  description = "ARN of the Feedback Capture Lambda"
  value       = module.feedback_lambda.function_arn
}

output "preference_lambda_arn" {
  description = "ARN of the Preference Update Lambda"
  value       = module.preference_lambda.function_arn
}

data "aws_region" "current" {}
