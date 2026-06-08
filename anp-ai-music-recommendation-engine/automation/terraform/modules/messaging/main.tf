#------------------------------------------------------------------------------
# Tier 2 — Messaging: SQS feedback queue + DLQ + EventBridge custom bus
#------------------------------------------------------------------------------

module "feedback_dlq" {
  source = "../aws/sqs"

  queue_name                = "${var.name_prefix}-feedback-dlq"
  is_fifo                   = false
  message_retention_seconds = 1209600
  kms_key_arn               = var.user_data_kms_key_arn
  name_prefix               = var.name_prefix
  common_tags               = var.common_tags
}

module "feedback_queue" {
  source = "../aws/sqs"

  queue_name                = "${var.name_prefix}-feedback-capture"
  is_fifo                   = false
  message_retention_seconds = var.sqs_feedback_queue_retention_seconds
  kms_key_arn               = var.user_data_kms_key_arn
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.feedback_dlq.queue_arn
    maxReceiveCount     = var.sqs_max_receive_count
  })
  name_prefix = var.name_prefix
  common_tags = var.common_tags
}

module "catalog_event_bus" {
  source = "../aws/eventbridge"

  bus_name    = var.eventbridge_catalog_bus_name
  name_prefix = var.name_prefix
  common_tags = var.common_tags
}
