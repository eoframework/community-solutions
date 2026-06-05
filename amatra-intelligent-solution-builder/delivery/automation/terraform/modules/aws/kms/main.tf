#------------------------------------------------------------------------------
# Tier 1: AWS KMS — Customer-Managed Key for encryption at rest
# Used by: S3 (SSE-KMS), CloudWatch Logs, Secrets Manager
#------------------------------------------------------------------------------

resource "aws_kms_key" "main" {
  description             = var.description
  deletion_window_in_days = 30
  enable_key_rotation     = var.enable_rotation
  multi_region            = false

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-cmk"
  })
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.name_prefix}-cmk"
  target_key_id = aws_kms_key.main.key_id
}
