output "sns_ops_alerts_arn" {
  description = "SNS ops alerts topic ARN"
  value       = module.sns_ops_alerts.topic_arn
}

output "cloudtrail_arn" {
  description = "CloudTrail trail ARN"
  value       = module.cloudtrail.trail_arn
}

output "cloudtrail_bucket_arn" {
  description = "CloudTrail S3 bucket ARN"
  value       = module.cloudtrail.cloudtrail_bucket_arn
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}
