output "log_archive_bucket_name" {
  description = "Name of the centralised S3 log archive bucket"
  value       = module.log_archive_bucket.bucket_name
}

output "log_archive_bucket_arn" {
  description = "ARN of the centralised S3 log archive bucket"
  value       = module.log_archive_bucket.bucket_arn
}

output "crr_destination_bucket_name" {
  description = "Name of the S3 CRR destination bucket in the DR region"
  value       = module.crr_destination_bucket.bucket_name
}

output "crr_destination_bucket_arn" {
  description = "ARN of the S3 CRR destination bucket"
  value       = module.crr_destination_bucket.bucket_arn
}

output "tf_state_bucket_name" {
  description = "Name of the Terraform state S3 bucket"
  value       = module.tf_state_bucket.bucket_name
}

output "tf_state_bucket_arn" {
  description = "ARN of the Terraform state S3 bucket"
  value       = module.tf_state_bucket.bucket_arn
}

output "s3_crr_role_arn" {
  description = "ARN of the S3 CRR IAM role"
  value       = aws_iam_role.s3_crr.arn
}
