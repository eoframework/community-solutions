output "sns_topic_arn_critical" {
  description = "ARN of the CRITICAL severity SNS topic"
  value       = module.sns_critical.topic_arn
}

output "sns_topic_arn_high" {
  description = "ARN of the HIGH severity SNS topic"
  value       = module.sns_high.topic_arn
}

output "sns_topic_arn_medium" {
  description = "ARN of the MEDIUM severity SNS topic"
  value       = module.sns_medium.topic_arn
}

output "cloudwatch_log_group_arns" {
  description = "Map of CloudWatch log group ARNs"
  value       = module.cloudwatch.log_group_arns
}

output "dashboard_arns" {
  description = "Map of CloudWatch dashboard ARNs"
  value       = module.cloudwatch.dashboard_arns
}

output "guardduty_eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule for GuardDuty high-severity findings"
  value       = aws_cloudwatch_event_rule.guardduty_high.arn
}

output "securityhub_eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule for Security Hub critical findings"
  value       = aws_cloudwatch_event_rule.securityhub_critical.arn
}
