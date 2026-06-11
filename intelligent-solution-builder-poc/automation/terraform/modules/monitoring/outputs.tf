output "sns_topic_arn" {
  description = "SNS alerts topic ARN"
  value       = module.cloudwatch.sns_topic_arn
}

output "sns_topic_name" {
  description = "SNS alerts topic name"
  value       = module.cloudwatch.sns_topic_name
}

output "cloudtrail_arn" {
  description = "CloudTrail trail ARN"
  value       = module.cloudtrail.trail_arn
}

output "cloudtrail_bucket_arn" {
  description = "CloudTrail S3 bucket ARN"
  value       = module.cloudtrail.trail_bucket_arn
}

output "dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = module.cloudwatch.dashboard_arn
}
