output "catalog_kms_key_arn" {
  description = "KMS key ARN for catalog data"
  value       = module.kms_catalog.key_arn
}

output "catalog_kms_key_id" {
  description = "KMS key ID for catalog data"
  value       = module.kms_catalog.key_id
}

output "user_data_kms_key_arn" {
  description = "KMS key ARN for user data"
  value       = module.kms_user_data.key_arn
}

output "model_kms_key_arn" {
  description = "KMS key ARN for model artifacts"
  value       = module.kms_model_artifacts.key_arn
}

output "app_security_group_id" {
  description = "Security group ID for Lambda/SageMaker application tier"
  value       = aws_security_group.app.id
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.main.arn
}

output "cognito_user_pool_id_ssm_param" {
  description = "SSM Parameter Store path for the Cognito User Pool ID"
  value       = aws_ssm_parameter.cognito_user_pool_id.name
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN (null when WAF is disabled)"
  value       = var.waf_enabled ? aws_wafv2_web_acl.api[0].arn : null
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID (null when GuardDuty is disabled)"
  value       = var.guardduty_enabled ? aws_guardduty_detector.main[0].id : null
}
