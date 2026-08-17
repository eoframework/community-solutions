output "ou_ids" {
  description = "Map of OU name to OU ID"
  value       = { for k, v in aws_organizations_organizational_unit.this : k => v.id }
}

output "policy_ids" {
  description = "Map of policy key to policy ID"
  value       = { for k, v in aws_organizations_policy.this : k => v.id }
}
