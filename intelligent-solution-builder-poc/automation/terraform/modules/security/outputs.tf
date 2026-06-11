output "kms_artifacts_key_arn" {
  description = "KMS artifacts key ARN"
  value       = module.kms_artifacts.key_arn
}

output "kms_database_key_arn" {
  description = "KMS database key ARN"
  value       = module.kms_database.key_arn
}

output "kms_secrets_key_arn" {
  description = "KMS secrets key ARN"
  value       = module.kms_secrets.key_arn
}

output "kms_audit_key_arn" {
  description = "KMS audit key ARN"
  value       = module.kms_audit.key_arn
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN (empty string if WAF disabled)"
  value       = var.enable_waf ? module.waf[0].web_acl_arn : ""
}

output "waf_web_acl_id" {
  description = "WAF Web ACL ID (empty string if WAF disabled)"
  value       = var.enable_waf ? module.waf[0].web_acl_id : ""
}
