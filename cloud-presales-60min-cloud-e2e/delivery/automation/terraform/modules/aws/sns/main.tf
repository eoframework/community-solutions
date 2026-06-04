#------------------------------------------------------------------------------
# Tier 1: AWS SNS — Notification topic for CloudWatch alarm routing
#------------------------------------------------------------------------------

resource "aws_sns_topic" "ops_alerts" {
  name = var.sns_topic_name
  tags = var.common_tags
}
