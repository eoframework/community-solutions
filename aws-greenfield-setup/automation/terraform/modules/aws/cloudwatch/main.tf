#------------------------------------------------------------------------------
# AWS CloudWatch Tier-1 Module
# Log Groups and Dashboard resources
#------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "this" {
  for_each          = var.log_groups
  name              = each.value.name
  retention_in_days = each.value.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = merge(var.common_tags, { Name = each.value.name })
}

resource "aws_cloudwatch_dashboard" "this" {
  for_each       = var.dashboards
  dashboard_name = each.value.name
  dashboard_body = each.value.body
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each            = var.metric_alarms
  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = lookup(each.value, "alarm_description", null)
  alarm_actions       = lookup(each.value, "alarm_actions", [])
  ok_actions          = lookup(each.value, "ok_actions", [])
  dimensions          = lookup(each.value, "dimensions", {})
  treat_missing_data  = lookup(each.value, "treat_missing_data", "missing")
  tags                = merge(var.common_tags, { Name = each.value.alarm_name })
}
