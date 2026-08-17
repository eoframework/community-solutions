#------------------------------------------------------------------------------
# AWS KMS Key Tier-1 Module
# Creates a customer-managed KMS key with rotation
#------------------------------------------------------------------------------

resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  multi_region            = var.multi_region
  policy                  = var.key_policy
  tags                    = merge(var.common_tags, { Name = var.key_alias })
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.key_alias}"
  target_key_id = aws_kms_key.this.key_id
}
