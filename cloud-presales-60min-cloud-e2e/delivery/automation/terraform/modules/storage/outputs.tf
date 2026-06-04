output "artifacts_bucket_name" {
  description = "S3 artifacts bucket name"
  value       = module.artifacts_bucket.bucket_name
}

output "artifacts_bucket_arn" {
  description = "S3 artifacts bucket ARN"
  value       = module.artifacts_bucket.bucket_arn
}

output "guidance_bucket_name" {
  description = "S3 guidance bucket name"
  value       = module.guidance_bucket.bucket_name
}

output "guidance_bucket_arn" {
  description = "S3 guidance bucket ARN"
  value       = module.guidance_bucket.bucket_arn
}

output "ecr_repository_url" {
  description = "ECR repository URL for agent container images"
  value       = module.ecr_repository.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecr_repository.repository_arn
}
