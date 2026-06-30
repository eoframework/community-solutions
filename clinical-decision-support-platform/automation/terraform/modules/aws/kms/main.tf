################################################################################
# Tier 1 — AWS KMS Module
# Creates a Customer Managed Key with automatic annual rotation.
################################################################################

resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  multi_region            = var.multi_region
  policy                  = var.key_policy

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-${var.key_alias_suffix}"
  })
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name_prefix}-${var.key_alias_suffix}"
  target_key_id = aws_kms_key.this.key_id
}
