output "artifact_bucket_id" {
  description = "Artifact S3 bucket name"
  value       = module.artifact_bucket.bucket_id
}

output "artifact_bucket_arn" {
  description = "Artifact S3 bucket ARN"
  value       = module.artifact_bucket.bucket_arn
}

output "guidance_bucket_id" {
  description = "Guidance S3 bucket name"
  value       = module.guidance_bucket.bucket_id
}

output "guidance_bucket_arn" {
  description = "Guidance S3 bucket ARN"
  value       = module.guidance_bucket.bucket_arn
}
