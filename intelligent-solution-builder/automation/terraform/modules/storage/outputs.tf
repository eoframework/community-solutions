output "artifacts_bucket_name" {
  description = "S3 artifacts bucket name"
  value       = module.artifacts_bucket.bucket_name
}

output "artifacts_bucket_arn" {
  description = "S3 artifacts bucket ARN"
  value       = module.artifacts_bucket.bucket_arn
}

output "templates_bucket_name" {
  description = "S3 templates bucket name"
  value       = module.templates_bucket.bucket_name
}

output "templates_bucket_arn" {
  description = "S3 templates bucket ARN"
  value       = module.templates_bucket.bucket_arn
}

output "cloudtrail_bucket_name" {
  description = "S3 CloudTrail audit log bucket name"
  value       = module.cloudtrail_bucket.bucket_name
}

output "cloudtrail_bucket_arn" {
  description = "S3 CloudTrail audit log bucket ARN"
  value       = module.cloudtrail_bucket.bucket_arn
}
