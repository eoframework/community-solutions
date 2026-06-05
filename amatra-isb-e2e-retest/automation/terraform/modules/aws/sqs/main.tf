#------------------------------------------------------------------------------
# AWS SQS Module - Tier 1 Provider Primitive
# Creates SQS FIFO queue (DLQ for GitHub push failures)
#------------------------------------------------------------------------------

resource "aws_sqs_queue" "main" {
  name                        = var.queue_name
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : false
  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  kms_master_key_id           = var.kms_key_id != "" ? var.kms_key_id : null

  tags = merge(var.common_tags, {
    Name = var.queue_name
  })
}

resource "aws_sqs_queue_policy" "main" {
  count     = var.queue_policy_json != "" ? 1 : 0
  queue_url = aws_sqs_queue.main.id
  policy    = var.queue_policy_json
}
