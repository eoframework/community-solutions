###############################################################################
# Tier 1 Provider Module — AWS SQS
# Creates a FIFO queue (or standard DLQ) with KMS encryption,
# message retention, and optional dead-letter queue linkage.
###############################################################################

resource "aws_sqs_queue" "main" {
  name                        = var.queue_name
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : false

  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  kms_master_key_id                 = var.kms_key_id
  kms_data_key_reuse_period_seconds = 300

  redrive_policy = var.dlq_arn != "" ? jsonencode({
    deadLetterTargetArn = var.dlq_arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = merge(var.common_tags, {
    Name = var.queue_name
  })
}
