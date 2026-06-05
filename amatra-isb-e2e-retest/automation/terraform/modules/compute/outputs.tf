output "ecr_repository_url" {
  description = "ECR repository URL for agent Docker image"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecr.repository_arn
}

output "lambda_api_handler_arn" {
  description = "API handler Lambda function ARN"
  value       = module.lambda_api_handler.function_arn
}

output "lambda_api_handler_name" {
  description = "API handler Lambda function name"
  value       = module.lambda_api_handler.function_name
}

output "lambda_api_handler_invoke_arn" {
  description = "API handler Lambda invoke ARN"
  value       = module.lambda_api_handler.invoke_arn
}

output "lambda_generation_initiator_arn" {
  description = "Generation initiator Lambda function ARN"
  value       = module.lambda_generation_initiator.function_arn
}

output "lambda_generation_initiator_invoke_arn" {
  description = "Generation initiator Lambda invoke ARN"
  value       = module.lambda_generation_initiator.invoke_arn
}

output "lambda_cognito_trigger_arn" {
  description = "Cognito post-confirmation trigger Lambda ARN"
  value       = module.lambda_cognito_trigger.function_arn
}

output "lambda_github_push_arn" {
  description = "GitHub push Lambda function ARN"
  value       = module.lambda_github_push.function_arn
}

output "lambda_agent_arns" {
  description = "Map of agent trigger Lambda ARNs"
  value = {
    input_validator     = module.lambda_agent_input_validator.function_arn
    presales_generator  = module.lambda_agent_presales_generator.function_arn
    delivery_generator  = module.lambda_agent_delivery_generator.function_arn
    code_generator      = module.lambda_agent_code_generator.function_arn
    eo_validator        = module.lambda_agent_eo_validator.function_arn
  }
}
