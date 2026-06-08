#------------------------------------------------------------------------------
# Tier 1 — AWS SQS: Standard queue with KMS encryption and optional DLQ
#------------------------------------------------------------------------------

resource "aws_sqs_queue" "main" {
  name                      = var.queue_name
  message_retention_seconds = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  kms_master_key_id                 = var.kms_key_arn
  kms_data_key_reuse_period_seconds = 300

  redrive_policy = var.redrive_policy

  tags = merge(var.common_tags, {
    Name = var.queue_name
  })
}
