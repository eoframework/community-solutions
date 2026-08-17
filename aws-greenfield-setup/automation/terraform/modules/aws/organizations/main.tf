#------------------------------------------------------------------------------
# AWS Organizations Tier-1 Module
# Manages Organizational Units and Policy attachments
#------------------------------------------------------------------------------

resource "aws_organizations_organizational_unit" "this" {
  for_each  = var.organizational_units
  name      = each.value.name
  parent_id = each.value.parent_id
  tags      = var.common_tags
}

resource "aws_organizations_policy" "this" {
  for_each    = var.policies
  name        = each.value.name
  description = each.value.description
  content     = each.value.content
  type        = each.value.type
  tags        = var.common_tags
}

resource "aws_organizations_policy_attachment" "this" {
  for_each  = var.policy_attachments
  policy_id = aws_organizations_policy.this[each.value.policy_key].id
  target_id = each.value.target_id
}
