output "budget_id" {
  description = "ID of the AWS Budget (null if not enabled)"
  value       = var.budgets_enabled ? module.budgets[0].budget_id : null
}

output "anomaly_monitor_arn" {
  description = "ARN of the Cost Anomaly Monitor (null if not enabled)"
  value       = var.cost_anomaly_detection_enabled ? aws_ce_anomaly_monitor.this[0].arn : null
}
