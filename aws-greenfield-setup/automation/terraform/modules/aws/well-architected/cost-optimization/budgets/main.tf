#------------------------------------------------------------------------------
# AWS Budgets Tier-1 Well-Architected Module (Cost Optimization)
# Per-account AWS Budget with tiered alerts
#------------------------------------------------------------------------------

resource "aws_budgets_budget" "this" {
  name         = var.budget_name
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_limit_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  dynamic "notification" {
    for_each = var.alert_thresholds
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = var.alert_emails
      subscriber_sns_topic_arns  = var.sns_topic_arns
    }
  }
}
