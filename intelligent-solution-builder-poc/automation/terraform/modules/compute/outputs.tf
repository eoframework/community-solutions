output "generation_queue_arn" {
  description = "SQS generation queue ARN"
  value       = module.sqs_generation.queue_arn
}

output "generation_queue_url" {
  description = "SQS generation queue URL"
  value       = module.sqs_generation.queue_url
}

output "generation_queue_name" {
  description = "SQS generation queue name"
  value       = module.sqs_generation.queue_name
}

output "dlq_arn" {
  description = "SQS DLQ ARN"
  value       = module.sqs_dlq.queue_arn
}

output "dlq_name" {
  description = "SQS DLQ name"
  value       = module.sqs_dlq.queue_name
}

output "step_functions_arn" {
  description = "Step Functions state machine ARN"
  value       = module.step_functions.state_machine_arn
}

output "step_functions_name" {
  description = "Step Functions state machine name"
  value       = module.step_functions.state_machine_name
}

output "lambda_arns" {
  description = "Map of Lambda function ARNs by function key"
  value       = { for k, v in module.lambda : k => v.function_arn }
}

output "lambda_invoke_arns" {
  description = "Map of Lambda invoke ARNs by function key"
  value       = { for k, v in module.lambda : k => v.invoke_arn }
}

output "ecr_repository_urls" {
  description = "Map of ECR repository URLs by function key"
  value       = { for k, v in module.ecr : k => v.repository_url }
}
