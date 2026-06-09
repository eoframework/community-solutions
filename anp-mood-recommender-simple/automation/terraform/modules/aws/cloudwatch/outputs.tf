#------------------------------------------------------------------------------
# AWS CloudWatch - Outputs
#------------------------------------------------------------------------------

output "sns_topic_arn" {
  description = "SNS topic ARN for ops notifications"
  value       = aws_sns_topic.ops.arn
}

output "operations_dashboard_name" {
  description = "Operations CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.operations.dashboard_name
}

output "cost_dashboard_name" {
  description = "Cost tracking CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.cost.dashboard_name
}
