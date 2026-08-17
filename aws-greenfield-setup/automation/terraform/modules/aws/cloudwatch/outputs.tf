output "log_group_arns" {
  description = "Map of log group key to ARN"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.arn }
}

output "log_group_names" {
  description = "Map of log group key to name"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}

output "dashboard_arns" {
  description = "Map of dashboard key to ARN"
  value       = { for k, v in aws_cloudwatch_dashboard.this : k => v.dashboard_arn }
}

output "alarm_arns" {
  description = "Map of alarm key to ARN"
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : k => v.arn }
}
