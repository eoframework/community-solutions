###############################################################################
# Tier 1 Provider Module — AWS KMS
# Creates customer-managed keys for the ISB platform data classification tiers.
###############################################################################

resource "aws_kms_key" "main" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  multi_region            = false

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-${var.key_purpose}"
  })
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.name_prefix}-${var.key_purpose}"
  target_key_id = aws_kms_key.main.key_id
}
