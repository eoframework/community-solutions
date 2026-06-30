output "stream_arn" {
  description = "Kinesis stream ARN"
  value       = aws_kinesis_stream.this.arn
}

output "stream_name" {
  description = "Kinesis stream name"
  value       = aws_kinesis_stream.this.name
}

output "dlq_arn" {
  description = "Dead-letter queue ARN"
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_url" {
  description = "Dead-letter queue URL"
  value       = aws_sqs_queue.dlq.id
}
