output "s3_key_arn" {
  description = "ARN of the KMS CMK for S3 encryption"
  value       = var.enable_s3_key ? aws_kms_key.s3[0].arn : null
}

output "s3_key_id" {
  description = "Key ID of the KMS CMK for S3 encryption"
  value       = var.enable_s3_key ? aws_kms_key.s3[0].key_id : null
}

output "dynamodb_key_arn" {
  description = "ARN of the KMS CMK for DynamoDB encryption"
  value       = var.enable_dynamodb_key ? aws_kms_key.dynamodb[0].arn : null
}

output "dynamodb_key_id" {
  description = "Key ID of the KMS CMK for DynamoDB encryption"
  value       = var.enable_dynamodb_key ? aws_kms_key.dynamodb[0].key_id : null
}

output "cloudtrail_key_arn" {
  description = "ARN of the KMS CMK for CloudTrail encryption"
  value       = var.enable_cloudtrail_key ? aws_kms_key.cloudtrail[0].arn : null
}

output "cloudtrail_key_id" {
  description = "Key ID of the KMS CMK for CloudTrail encryption"
  value       = var.enable_cloudtrail_key ? aws_kms_key.cloudtrail[0].key_id : null
}

output "secrets_key_arn" {
  description = "ARN of the KMS CMK for Secrets Manager encryption"
  value       = var.enable_secrets_key ? aws_kms_key.secrets[0].arn : null
}

output "secrets_key_id" {
  description = "Key ID of the KMS CMK for Secrets Manager encryption"
  value       = var.enable_secrets_key ? aws_kms_key.secrets[0].key_id : null
}
