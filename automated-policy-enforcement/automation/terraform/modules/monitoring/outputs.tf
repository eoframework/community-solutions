output "sns_topic_arn" {
  description = "ARN of the platform alerting SNS topic"
  value       = aws_sns_topic.platform_alerts.arn
}

output "sns_topic_name" {
  description = "Name of the platform alerting SNS topic"
  value       = aws_sns_topic.platform_alerts.name
}

output "dashboard_platform_ops_url" {
  description = "CloudWatch console URL for the platform operations dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home#dashboards:name=${aws_cloudwatch_dashboard.platform_ops.dashboard_name}"
}

output "dashboard_identity_url" {
  description = "CloudWatch console URL for the identity and access dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home#dashboards:name=${aws_cloudwatch_dashboard.identity_access.dashboard_name}"
}

output "dashboard_dr_url" {
  description = "CloudWatch console URL for the DR replication dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home#dashboards:name=${aws_cloudwatch_dashboard.dr_replication.dashboard_name}"
}

output "platform_log_group_name" {
  description = "Name of the platform CloudWatch log group"
  value       = aws_cloudwatch_log_group.platform.name
}
