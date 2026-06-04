output "trail_arn" {
  description = "CloudTrail trail ARN"
  value       = aws_cloudtrail.main.arn
}

output "trail_name" {
  description = "CloudTrail trail name"
  value       = aws_cloudtrail.main.name
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN for CloudTrail forwarded logs"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}
