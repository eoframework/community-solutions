output "feedback_queue_url" {
  description = "SQS feedback capture queue URL"
  value       = module.feedback_queue.queue_url
}

output "feedback_queue_arn" {
  description = "SQS feedback capture queue ARN"
  value       = module.feedback_queue.queue_arn
}

output "feedback_queue_name" {
  description = "SQS feedback capture queue name"
  value       = module.feedback_queue.queue_name
}

output "feedback_dlq_url" {
  description = "SQS feedback DLQ URL"
  value       = module.feedback_dlq.queue_url
}

output "feedback_dlq_arn" {
  description = "SQS feedback DLQ ARN"
  value       = module.feedback_dlq.queue_arn
}

output "feedback_dlq_name" {
  description = "SQS feedback DLQ name"
  value       = module.feedback_dlq.queue_name
}

output "catalog_event_bus_arn" {
  description = "EventBridge catalog upload event bus ARN"
  value       = module.catalog_event_bus.event_bus_arn
}

output "catalog_event_bus_name" {
  description = "EventBridge catalog upload event bus name"
  value       = module.catalog_event_bus.event_bus_name
}
