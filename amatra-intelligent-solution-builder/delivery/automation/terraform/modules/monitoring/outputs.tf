output "sns_topic_arn" {
  description = "SNS alarm topic ARN"
  value       = aws_sns_topic.alarms.arn
}

output "sns_topic_name" {
  description = "SNS alarm topic name"
  value       = aws_sns_topic.alarms.name
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "log_group_name" {
  description = "CloudWatch platform log group name"
  value       = aws_cloudwatch_log_group.platform.name
}

output "log_group_arn" {
  description = "CloudWatch platform log group ARN"
  value       = aws_cloudwatch_log_group.platform.arn
}
