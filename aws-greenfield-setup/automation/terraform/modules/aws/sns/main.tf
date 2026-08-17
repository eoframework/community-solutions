#------------------------------------------------------------------------------
# AWS SNS Topic Tier-1 Module
# Creates an SNS topic with optional KMS encryption and email subscriptions
#------------------------------------------------------------------------------

resource "aws_sns_topic" "this" {
  name              = var.topic_name
  kms_master_key_id = var.kms_key_id
  tags              = merge(var.common_tags, { Name = var.topic_name })
}

resource "aws_sns_topic_policy" "this" {
  count  = var.topic_policy != null ? 1 : 0
  arn    = aws_sns_topic.this.arn
  policy = var.topic_policy
}

resource "aws_sns_topic_subscription" "email" {
  for_each  = toset(var.email_subscriptions)
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = each.value
}
