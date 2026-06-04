output "sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications"
  value       = module.sns.topic_arn
}

output "sns_topic_name" {
  description = "SNS topic name"
  value       = module.sns.topic_name
}

output "dashboard_platform_health_name" {
  description = "Platform health CloudWatch dashboard name"
  value       = module.cloudwatch_dashboards.dashboard_platform_health_name
}

output "dashboard_throughput_name" {
  description = "Solution throughput CloudWatch dashboard name"
  value       = module.cloudwatch_dashboards.dashboard_throughput_name
}

output "dashboard_cost_telemetry_name" {
  description = "Cost telemetry CloudWatch dashboard name"
  value       = module.cloudwatch_dashboards.dashboard_cost_telemetry_name
}

output "dashboard_quota_utilisation_name" {
  description = "Quota utilisation CloudWatch dashboard name"
  value       = module.cloudwatch_dashboards.dashboard_quota_utilisation_name
}
