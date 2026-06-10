output "job_queue_url" {
  description = "SQS job queue URL"
  value       = module.sqs.queue_url
}

output "job_queue_arn" {
  description = "SQS job queue ARN"
  value       = module.sqs.queue_arn
}

output "job_queue_name" {
  description = "SQS job queue name"
  value       = module.sqs.queue_name
}

output "dlq_url" {
  description = "SQS Dead Letter Queue URL"
  value       = module.sqs.dlq_url
}

output "dlq_arn" {
  description = "SQS Dead Letter Queue ARN"
  value       = module.sqs.dlq_arn
}

output "dlq_name" {
  description = "SQS Dead Letter Queue name"
  value       = module.sqs.dlq_name
}
