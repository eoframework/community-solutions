output "log_archive_bucket_id" {
  description = "Name of the Log Archive S3 bucket"
  value       = module.log_archive_bucket.bucket_id
}

output "log_archive_bucket_arn" {
  description = "ARN of the Log Archive S3 bucket"
  value       = module.log_archive_bucket.bucket_arn
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = module.cloudtrail.trail_arn
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  value       = module.cloudtrail.trail_name
}

output "cloudtrail_lake_event_store_arn" {
  description = "ARN of the CloudTrail Lake event data store (null if not enabled)"
  value       = var.enable_cloudtrail_lake ? aws_cloudtrail_event_data_store.this[0].arn : null
}
