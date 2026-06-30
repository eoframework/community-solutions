output "sns_topic_arn" {
  description = "SNS alarms topic ARN"
  value       = aws_sns_topic.alarms.arn
}

output "sns_topic_name" {
  description = "SNS alarms topic name"
  value       = aws_sns_topic.alarms.name
}

output "dashboard_application_name" {
  description = "Application CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.application.dashboard_name
}

output "dashboard_ml_name" {
  description = "ML Inference CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.ml_inference.dashboard_name
}

output "config_recorder_name" {
  description = "AWS Config recorder name"
  value       = var.monitoring.enable_config ? aws_config_configuration_recorder.this[0].name : null
}
