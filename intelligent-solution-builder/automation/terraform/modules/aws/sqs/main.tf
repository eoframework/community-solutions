#------------------------------------------------------------------------------
# Tier 1 — AWS SQS Queue primitive
# Standard SQS queue with KMS encryption and DLQ support
#------------------------------------------------------------------------------

resource "aws_sqs_queue" "dlq" {
  name                       = "${var.queue_name}-dlq"
  message_retention_seconds  = var.dlq_message_retention_seconds
  kms_master_key_id          = var.kms_key_arn
  kms_data_key_reuse_period_seconds = 300

  tags = merge(var.common_tags, {
    Name    = "${var.queue_name}-dlq"
    Purpose = "DeadLetterQueue"
  })
}

resource "aws_sqs_queue" "this" {
  name                       = var.queue_name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  kms_master_key_id          = var.kms_key_arn
  kms_data_key_reuse_period_seconds = 300

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = merge(var.common_tags, {
    Name = var.queue_name
  })
}
