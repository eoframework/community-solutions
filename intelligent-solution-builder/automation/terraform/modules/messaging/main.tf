#------------------------------------------------------------------------------
# Tier 2 — Messaging Module
# Composes: aws/sqs — job queue and DLQ for async generation pipeline
#------------------------------------------------------------------------------

module "sqs" {
  source = "../aws/sqs"

  queue_name                     = var.job_queue_name
  visibility_timeout_seconds     = var.visibility_timeout_seconds
  message_retention_seconds      = var.message_retention_seconds
  max_receive_count              = var.max_receive_count
  dlq_message_retention_seconds = 1209600
  kms_key_arn                    = var.kms_key_arn
  common_tags                    = var.common_tags
}
