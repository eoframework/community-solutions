output "raw_catalog_bucket_name" {
  description = "S3 bucket name for raw catalog files"
  value       = module.raw_catalog.bucket_name
}

output "raw_catalog_bucket_arn" {
  description = "S3 bucket ARN for raw catalog files"
  value       = module.raw_catalog.bucket_arn
}

output "transcripts_bucket_name" {
  description = "S3 bucket name for transcript files"
  value       = module.transcripts.bucket_name
}

output "features_bucket_name" {
  description = "S3 bucket name for audio feature vectors"
  value       = module.features.bucket_name
}

output "models_bucket_name" {
  description = "S3 bucket name for SageMaker model artifacts"
  value       = module.models.bucket_name
}

output "models_bucket_arn" {
  description = "S3 bucket ARN for SageMaker model artifacts"
  value       = module.models.bucket_arn
}

output "cloudtrail_bucket_name" {
  description = "S3 bucket name for CloudTrail audit logs"
  value       = module.cloudtrail_logs.bucket_name
}

output "cloudtrail_bucket_arn" {
  description = "S3 bucket ARN for CloudTrail audit logs"
  value       = module.cloudtrail_logs.bucket_arn
}
