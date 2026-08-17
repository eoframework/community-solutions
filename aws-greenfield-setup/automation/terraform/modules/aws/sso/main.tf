#------------------------------------------------------------------------------
# AWS IAM Identity Center (SSO) Tier-1 Module
# Manages Permission Sets and Account Assignments
#------------------------------------------------------------------------------

resource "aws_ssoadmin_permission_set" "this" {
  for_each         = var.permission_sets
  name             = each.value.name
  description      = each.value.description
  instance_arn     = var.sso_instance_arn
  session_duration = each.value.session_duration
  tags             = var.common_tags
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each           = var.managed_policy_attachments
  instance_arn       = var.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_key].arn
  managed_policy_arn = each.value.managed_policy_arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each           = var.inline_policies
  instance_arn       = var.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  inline_policy      = each.value
}
