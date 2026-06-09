#------------------------------------------------------------------------------
# Tier 1: AWS KMS — Customer Managed Key for platform encryption
# Used by: S3 (log archive, TF state), DynamoDB, Lambda environment variables
#------------------------------------------------------------------------------

resource "aws_kms_key" "main" {
  description             = "${var.name_prefix} platform CMK — encrypts log archive, DynamoDB, and Lambda secrets"
  enable_key_rotation     = var.rotation_enabled
  deletion_window_in_days = 30
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-cmk"
  })
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.name_prefix}-platform"
  target_key_id = aws_kms_key.main.key_id
}
