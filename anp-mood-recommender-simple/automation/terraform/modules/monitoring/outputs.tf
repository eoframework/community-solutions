#------------------------------------------------------------------------------
# Monitoring Module (Tier 2) - Outputs
#------------------------------------------------------------------------------

output "sns_topic_arn" {
  description = "SNS ops topic ARN"
  value       = module.cloudwatch.sns_topic_arn
}

output "operations_dashboard_name" {
  description = "Operations CloudWatch dashboard name"
  value       = module.cloudwatch.operations_dashboard_name
}

output "cost_dashboard_name" {
  description = "Cost CloudWatch dashboard name"
  value       = module.cloudwatch.cost_dashboard_name
}
