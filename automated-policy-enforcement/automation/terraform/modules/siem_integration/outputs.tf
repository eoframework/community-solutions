output "lambda_arn" {
  description = "ARN of the SIEM forwarding Lambda function"
  value       = aws_lambda_function.siem_forward.arn
}

output "lambda_name" {
  description = "Name of the SIEM forwarding Lambda function"
  value       = aws_lambda_function.siem_forward.function_name
}

output "dlq_url" {
  description = "URL of the SIEM forwarding dead-letter queue"
  value       = aws_sqs_queue.dlq.url
}

output "dlq_arn" {
  description = "ARN of the SIEM forwarding dead-letter queue"
  value       = aws_sqs_queue.dlq.arn
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule capturing Security Hub findings"
  value       = aws_cloudwatch_event_rule.security_hub_findings.arn
}
