output "sns_topic_arn" {
  description = "SNS alerts topic ARN"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "SNS alerts topic name"
  value       = aws_sns_topic.alerts.name
}

output "dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}
