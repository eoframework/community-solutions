output "ou_ids" {
  description = "Map of OU name to OU ID"
  value       = module.organizations.ou_ids
}

output "policy_ids" {
  description = "Map of policy key to policy ID"
  value       = module.organizations.policy_ids
}

output "permission_set_arns" {
  description = "Map of permission set key to ARN"
  value       = module.sso.permission_set_arns
}
