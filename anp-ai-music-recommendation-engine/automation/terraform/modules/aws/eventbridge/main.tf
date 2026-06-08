#------------------------------------------------------------------------------
# Tier 1 — AWS EventBridge: Custom event bus for catalog upload events
#------------------------------------------------------------------------------

resource "aws_cloudwatch_event_bus" "main" {
  name = var.bus_name

  tags = merge(var.common_tags, {
    Name = var.bus_name
  })
}
