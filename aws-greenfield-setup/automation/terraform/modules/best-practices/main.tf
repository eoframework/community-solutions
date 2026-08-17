#------------------------------------------------------------------------------
# Best Practices Module (Tier 2)
# Composes: aws/well-architected/cost-optimization/budgets
# Manages: AWS Budgets, Cost Anomaly Detection, Config recording baseline
#------------------------------------------------------------------------------

module "budgets" {
  source = "../aws/well-architected/cost-optimization/budgets"

  count = var.budgets_enabled ? 1 : 0

  budget_name       = "${var.name_prefix}-monthly-budget"
  monthly_limit_usd = var.monthly_budget_usd
  alert_thresholds  = var.budget_alert_thresholds
  alert_emails      = var.budget_alert_emails
  sns_topic_arns    = var.budget_sns_topic_arns
}

resource "aws_ce_anomaly_monitor" "this" {
  count             = var.cost_anomaly_detection_enabled ? 1 : 0
  name              = "${var.name_prefix}-anomaly-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
  tags              = merge(var.common_tags, { Name = "${var.name_prefix}-anomaly-monitor" })
}

resource "aws_ce_anomaly_subscription" "this" {
  count      = var.cost_anomaly_detection_enabled ? 1 : 0
  name       = "${var.name_prefix}-anomaly-subscription"
  frequency  = "DAILY"
  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = [tostring(var.anomaly_threshold_usd)]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }
  monitor_arn_list = [aws_ce_anomaly_monitor.this[0].arn]
  subscriber {
    type    = "SNS"
    address = var.sns_topic_arn_medium
  }
  tags = merge(var.common_tags, { Name = "${var.name_prefix}-anomaly-subscription" })
}
