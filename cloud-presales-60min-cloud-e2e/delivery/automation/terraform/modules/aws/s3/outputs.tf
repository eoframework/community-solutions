output "artifacts_bucket_name" {
  description = "Artifacts S3 bucket name"
  value       = aws_s3_bucket.artifacts.id
}

output "artifacts_bucket_arn" {
  description = "Artifacts S3 bucket ARN"
  value       = aws_s3_bucket.artifacts.arn
}

output "guidance_bucket_name" {
  description = "Guidance S3 bucket name"
  value       = aws_s3_bucket.guidance.id
}

output "guidance_bucket_arn" {
  description = "Guidance S3 bucket ARN"
  value       = aws_s3_bucket.guidance.arn
}

output "cloudtrail_bucket_name" {
  description = "CloudTrail log S3 bucket name"
  value       = aws_s3_bucket.cloudtrail.id
}

output "cloudtrail_bucket_arn" {
  description = "CloudTrail log S3 bucket ARN"
  value       = aws_s3_bucket.cloudtrail.arn
}
