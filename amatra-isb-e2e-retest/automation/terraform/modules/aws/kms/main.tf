#------------------------------------------------------------------------------
# AWS KMS Module - Tier 1 Provider Primitive
# Creates Customer Managed Keys for encryption at rest
#------------------------------------------------------------------------------

resource "aws_kms_key" "main" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  rotation_period_in_days = var.rotation_period_in_days
  multi_region            = false

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-kms"
  })
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.name_prefix}-${var.key_alias_suffix}"
  target_key_id = aws_kms_key.main.key_id
}
