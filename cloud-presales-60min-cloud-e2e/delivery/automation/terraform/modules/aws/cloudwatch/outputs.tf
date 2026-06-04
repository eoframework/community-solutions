output "dashboard_platform_health_name" {
  description = "Platform health dashboard name"
  value       = aws_cloudwatch_dashboard.platform_health.dashboard_name
}

output "dashboard_throughput_name" {
  description = "Solution throughput dashboard name"
  value       = aws_cloudwatch_dashboard.throughput.dashboard_name
}

output "dashboard_cost_telemetry_name" {
  description = "Cost telemetry dashboard name"
  value       = aws_cloudwatch_dashboard.cost_telemetry.dashboard_name
}

output "dashboard_quota_utilisation_name" {
  description = "Quota utilisation dashboard name"
  value       = aws_cloudwatch_dashboard.quota_utilisation.dashboard_name
}
