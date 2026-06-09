#------------------------------------------------------------------------------
# Storage Module (Tier 2) - Outputs
#------------------------------------------------------------------------------

output "bucket_id" {
  description = "S3 catalog bucket name"
  value       = module.catalog_bucket.bucket_id
}

output "bucket_arn" {
  description = "S3 catalog bucket ARN"
  value       = module.catalog_bucket.bucket_arn
}
