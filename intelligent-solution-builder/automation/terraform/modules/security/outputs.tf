output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.this.id
}

output "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.this.arn
}

output "cognito_client_id" {
  description = "Cognito App Client ID"
  value       = aws_cognito_user_pool_client.this.id
}

output "waf_web_acl_arn" {
  description = "WAF WebACL ARN (null when WAF is disabled)"
  value       = var.enable_waf ? aws_wafv2_web_acl.api[0].arn : null
}

output "waf_web_acl_id" {
  description = "WAF WebACL ID (null when WAF is disabled)"
  value       = var.enable_waf ? aws_wafv2_web_acl.api[0].id : null
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID (null when disabled)"
  value       = var.enable_guardduty ? aws_guardduty_detector.this[0].id : null
}
