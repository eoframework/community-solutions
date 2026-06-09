#------------------------------------------------------------------------------
# Processing Module (Tier 2) - Outputs
#------------------------------------------------------------------------------

output "classifier_function_name" {
  description = "Classifier Lambda function name"
  value       = module.classifier.function_name
}

output "classifier_function_arn" {
  description = "Classifier Lambda function ARN"
  value       = module.classifier.function_arn
}

output "classifier_invoke_arn" {
  description = "Classifier Lambda invocation ARN"
  value       = module.classifier.invoke_arn
}

output "recommender_function_name" {
  description = "Recommender Lambda function name"
  value       = module.recommender.function_name
}

output "recommender_function_arn" {
  description = "Recommender Lambda function ARN"
  value       = module.recommender.function_arn
}

output "recommender_invoke_arn" {
  description = "Recommender Lambda invocation ARN"
  value       = module.recommender.invoke_arn
}

output "autotagger_function_name" {
  description = "Auto-Tagger Lambda function name"
  value       = module.autotagger.function_name
}

output "autotagger_function_arn" {
  description = "Auto-Tagger Lambda function ARN"
  value       = module.autotagger.function_arn
}

output "autotagger_dlq_arn" {
  description = "Auto-Tagger DLQ ARN"
  value       = module.autotagger_dlq.queue_arn
}

output "autotagger_dlq_name" {
  description = "Auto-Tagger DLQ name"
  value       = module.autotagger_dlq.queue_name
}
