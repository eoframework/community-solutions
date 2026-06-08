#------------------------------------------------------------------------------
# Tier 1 — AWS SNS: Alert topic for operational notifications
#------------------------------------------------------------------------------

resource "aws_sns_topic" "main" {
  name = var.topic_name

  tags = merge(var.common_tags, {
    Name = var.topic_name
  })
}
