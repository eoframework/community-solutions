output "kms_s3_key_arn" {
  description = "KMS CMK ARN for S3 artifact bucket"
  value       = module.kms_s3.key_arn
}

output "kms_s3_key_id" {
  description = "KMS CMK key ID for S3 artifact bucket"
  value       = module.kms_s3.key_id
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = module.cognito.user_pool_arn
}

output "cognito_app_client_id" {
  description = "Cognito App Client ID"
  value       = module.cognito.app_client_id
}

output "cognito_endpoint" {
  description = "Cognito User Pool endpoint"
  value       = module.cognito.endpoint
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = var.security.guardduty_enabled ? aws_guardduty_detector.main[0].id : null
}
