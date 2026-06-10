output "queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.this.url
}

output "queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.this.arn
}

output "queue_name" {
  description = "SQS queue name"
  value       = aws_sqs_queue.this.name
}

output "dlq_url" {
  description = "SQS Dead Letter Queue URL"
  value       = aws_sqs_queue.dlq.url
}

output "dlq_arn" {
  description = "SQS Dead Letter Queue ARN"
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_name" {
  description = "SQS Dead Letter Queue name"
  value       = aws_sqs_queue.dlq.name
}
