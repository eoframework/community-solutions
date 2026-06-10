output "api_submit_lambda_name" {
  description = "API submit Lambda function name"
  value       = module.api_submit.function_name
}

output "api_submit_lambda_arn" {
  description = "API submit Lambda function ARN"
  value       = module.api_submit.function_arn
}

output "api_submit_alias_arn" {
  description = "API submit Lambda alias ARN (for API Gateway)"
  value       = module.api_submit.alias_arn
}

output "api_status_lambda_name" {
  description = "API status Lambda function name"
  value       = module.api_status.function_name
}

output "api_status_lambda_arn" {
  description = "API status Lambda function ARN"
  value       = module.api_status.function_arn
}

output "api_status_alias_arn" {
  description = "API status Lambda alias ARN"
  value       = module.api_status.alias_arn
}

output "api_retrieve_lambda_name" {
  description = "API retrieve Lambda function name"
  value       = module.api_retrieve.function_name
}

output "api_retrieve_lambda_arn" {
  description = "API retrieve Lambda function ARN"
  value       = module.api_retrieve.function_arn
}

output "api_retrieve_alias_arn" {
  description = "API retrieve Lambda alias ARN"
  value       = module.api_retrieve.alias_arn
}

output "api_admin_lambda_name" {
  description = "API admin Lambda function name"
  value       = module.api_admin.function_name
}

output "api_admin_lambda_arn" {
  description = "API admin Lambda function ARN"
  value       = module.api_admin.function_arn
}

output "api_admin_alias_arn" {
  description = "API admin Lambda alias ARN"
  value       = module.api_admin.alias_arn
}

output "orchestrator_start_lambda_name" {
  description = "Orchestrator start Lambda function name"
  value       = module.orchestrator_start.function_name
}

output "orchestrator_start_lambda_arn" {
  description = "Orchestrator start Lambda function ARN"
  value       = module.orchestrator_start.function_arn
}

output "bedrock_sonnet_lambda_name" {
  description = "Bedrock Sonnet invoker Lambda function name"
  value       = module.bedrock_sonnet.function_name
}

output "bedrock_sonnet_lambda_arn" {
  description = "Bedrock Sonnet invoker Lambda function ARN"
  value       = module.bedrock_sonnet.function_arn
}

output "bedrock_haiku_lambda_name" {
  description = "Bedrock Haiku invoker Lambda function name"
  value       = module.bedrock_haiku.function_name
}

output "bedrock_haiku_lambda_arn" {
  description = "Bedrock Haiku invoker Lambda function ARN"
  value       = module.bedrock_haiku.function_arn
}

output "artifact_processor_lambda_name" {
  description = "Artifact processor Lambda function name"
  value       = module.artifact_processor.function_name
}

output "artifact_processor_lambda_arn" {
  description = "Artifact processor Lambda function ARN"
  value       = module.artifact_processor.function_arn
}
