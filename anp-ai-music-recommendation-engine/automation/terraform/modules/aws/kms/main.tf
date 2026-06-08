#------------------------------------------------------------------------------
# Tier 1 — AWS KMS: Customer Managed Key with alias and rotation policy
#------------------------------------------------------------------------------

resource "aws_kms_key" "main" {
  description             = var.description
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
  multi_region            = false

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-${replace(var.key_alias, "alias/", "")}"
  })
}

resource "aws_kms_alias" "main" {
  name          = var.key_alias
  target_key_id = aws_kms_key.main.key_id
}
