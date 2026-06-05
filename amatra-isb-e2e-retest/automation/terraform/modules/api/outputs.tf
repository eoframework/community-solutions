output "api_id" {
  description = "API Gateway ID"
  value       = module.api_gateway.api_id
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_endpoint
}

output "execution_arn" {
  description = "API Gateway execution ARN"
  value       = module.api_gateway.execution_arn
}

output "authorizer_id" {
  description = "Cognito JWT authoriser ID"
  value       = module.api_gateway.authorizer_id
}

output "github_dlq_url" {
  description = "GitHub push DLQ URL"
  value       = module.github_dlq.queue_url
}

output "github_dlq_arn" {
  description = "GitHub push DLQ ARN"
  value       = module.github_dlq.queue_arn
}
