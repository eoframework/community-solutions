#------------------------------------------------------------------------------
# AWS SNS Module - Tier 1 Provider Primitive
# Creates SNS topic for operational alerts
#------------------------------------------------------------------------------

resource "aws_sns_topic" "main" {
  name              = var.topic_name
  kms_master_key_id = var.kms_key_id != "" ? var.kms_key_id : null

  tags = merge(var.common_tags, {
    Name = var.topic_name
  })
}

resource "aws_sns_topic_subscription" "email" {
  count     = length(var.email_subscriptions)
  topic_arn = aws_sns_topic.main.arn
  protocol  = "email"
  endpoint  = var.email_subscriptions[count.index]
}
