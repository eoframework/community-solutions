output "waf_web_acl_arn" {
  description = "WAF WebACL ARN (null when WAF is disabled)"
  value       = var.waf_managed_rules_enabled ? module.waf[0].web_acl_arn : null
}

output "waf_web_acl_id" {
  description = "WAF WebACL ID (null when WAF is disabled)"
  value       = var.waf_managed_rules_enabled ? module.waf[0].web_acl_id : null
}

output "cloudtrail_arn" {
  description = "CloudTrail trail ARN (null when disabled)"
  value       = var.cloudtrail_enabled ? module.cloudtrail[0].trail_arn : null
}
