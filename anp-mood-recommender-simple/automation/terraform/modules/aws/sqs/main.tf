#------------------------------------------------------------------------------
# AWS SQS Queue - Tier 1 Provider Module
#------------------------------------------------------------------------------

resource "aws_sqs_queue" "this" {
  name                       = var.queue_name
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  tags = var.common_tags
}
