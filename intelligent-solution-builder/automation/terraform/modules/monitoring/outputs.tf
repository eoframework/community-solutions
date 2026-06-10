output "sns_topic_arn" {
  description = "SNS alerts topic ARN"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "SNS alerts topic name"
  value       = aws_sns_topic.alerts.name
}

output "operations_dashboard_name" {
  description = "CloudWatch Operations Dashboard name"
  value       = aws_cloudwatch_dashboard.operations.dashboard_name
}

output "sla_dashboard_name" {
  description = "CloudWatch SLA Dashboard name"
  value       = aws_cloudwatch_dashboard.sla.dashboard_name
}

output "quality_dashboard_name" {
  description = "CloudWatch Quality Dashboard name"
  value       = aws_cloudwatch_dashboard.quality.dashboard_name
}
