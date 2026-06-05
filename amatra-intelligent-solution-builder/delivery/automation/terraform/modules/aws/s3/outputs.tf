output "artifact_bucket_name" {
  description = "Artifact S3 bucket name"
  value       = aws_s3_bucket.artifacts.id
}

output "artifact_bucket_arn" {
  description = "Artifact S3 bucket ARN"
  value       = aws_s3_bucket.artifacts.arn
}

output "cloudtrail_bucket_name" {
  description = "CloudTrail audit S3 bucket name"
  value       = var.cloudtrail_enabled ? aws_s3_bucket.cloudtrail[0].id : ""
}

output "cloudtrail_bucket_arn" {
  description = "CloudTrail audit S3 bucket ARN"
  value       = var.cloudtrail_enabled ? aws_s3_bucket.cloudtrail[0].arn : ""
}
