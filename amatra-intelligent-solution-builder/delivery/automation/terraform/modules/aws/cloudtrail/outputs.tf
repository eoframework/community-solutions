output "trail_arn" {
  description = "CloudTrail trail ARN"
  value       = var.enabled ? aws_cloudtrail.main[0].arn : ""
}

output "trail_name" {
  description = "CloudTrail trail name"
  value       = var.enabled ? aws_cloudtrail.main[0].name : ""
}
