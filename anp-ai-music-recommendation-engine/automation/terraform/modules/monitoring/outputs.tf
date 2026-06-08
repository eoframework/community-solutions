output "sns_topic_arn" {
  description = "SNS topic ARN for operational alerts"
  value       = module.sns.topic_arn
}

output "sns_topic_name" {
  description = "SNS topic name for operational alerts"
  value       = module.sns.topic_name
}

output "api_dashboard_name" {
  description = "CloudWatch API health dashboard name"
  value       = aws_cloudwatch_dashboard.api_health.dashboard_name
}

output "ml_dashboard_name" {
  description = "CloudWatch ML pipeline dashboard name"
  value       = aws_cloudwatch_dashboard.ml_pipeline.dashboard_name
}

output "business_dashboard_name" {
  description = "CloudWatch business metrics dashboard name"
  value       = aws_cloudwatch_dashboard.business_metrics.dashboard_name
}
