output "lambda_arn" {
  description = "ARN of the Config auto-remediation Lambda function"
  value       = aws_lambda_function.config_remediation.arn
}

output "lambda_name" {
  description = "Name of the Config auto-remediation Lambda function"
  value       = aws_lambda_function.config_remediation.function_name
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule for Config non-compliant events"
  value       = aws_cloudwatch_event_rule.config_noncompliant.arn
}
