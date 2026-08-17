#------------------------------------------------------------------------------
# Monitoring Module (Tier 2)
# Composes: aws/sns, aws/cloudwatch
# Manages: SNS topics for tiered alerting, CloudWatch dashboards, alarms,
#          EventBridge rules for GuardDuty/Security Hub findings
#------------------------------------------------------------------------------

module "sns_critical" {
  source = "../aws/sns"

  topic_name = "${var.name_prefix}-alerts-critical"
  kms_key_id = var.kms_key_id
  common_tags = merge(var.common_tags, { AlertSeverity = "CRITICAL" })
}

module "sns_high" {
  source = "../aws/sns"

  topic_name = "${var.name_prefix}-alerts-high"
  kms_key_id = var.kms_key_id
  common_tags = merge(var.common_tags, { AlertSeverity = "HIGH" })
}

module "sns_medium" {
  source = "../aws/sns"

  topic_name = "${var.name_prefix}-alerts-medium"
  kms_key_id = var.kms_key_id
  common_tags = merge(var.common_tags, { AlertSeverity = "MEDIUM" })
}

module "cloudwatch" {
  source = "../aws/cloudwatch"

  log_groups = {
    platform = {
      name              = "/aws/landing-zone/${var.name_prefix}"
      retention_in_days = var.log_retention_days
    }
  }

  dashboards = {
    ops = {
      name = var.dashboard_name_ops
      body = jsonencode({
        widgets = [
          {
            type = "text"
            x    = 0
            y    = 0
            width = 24
            height = 2
            properties = {
              markdown = "## Landing Zone Operations Dashboard\nMonitors Control Tower compliance, AFT pipeline health, and network status."
            }
          }
        ]
      })
    }
    security = {
      name = var.dashboard_name_security
      body = jsonencode({
        widgets = [
          {
            type = "text"
            x    = 0
            y    = 0
            width = 24
            height = 2
            properties = {
              markdown = "## Security Posture Dashboard\nSecurity Hub FSBP score, GuardDuty findings, and Config compliance."
            }
          }
        ]
      })
    }
    finops = {
      name = var.dashboard_name_finops
      body = jsonencode({
        widgets = [
          {
            type = "text"
            x    = 0
            y    = 0
            width = 24
            height = 2
            properties = {
              markdown = "## FinOps Dashboard\nOrg-wide cost trend, top accounts by spend, and Budget alert status."
            }
          }
        ]
      })
    }
  }

  kms_key_arn = var.kms_key_arn
  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# EventBridge rules for GuardDuty and Security Hub findings
#------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "guardduty_high" {
  name        = "${var.name_prefix}-guardduty-high-severity"
  description = "Route GuardDuty findings severity >= ${var.guardduty_alert_threshold} to HIGH SNS topic"
  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [{ numeric = [">=", var.guardduty_alert_threshold] }]
    }
  })
  tags = merge(var.common_tags, { Name = "${var.name_prefix}-guardduty-high-severity" })
}

resource "aws_cloudwatch_event_target" "guardduty_high_sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_high.name
  target_id = "GuardDutyHighSNS"
  arn       = module.sns_high.topic_arn
}

resource "aws_cloudwatch_event_rule" "securityhub_critical" {
  name        = "${var.name_prefix}-securityhub-critical"
  description = "Route Security Hub CRITICAL findings to CRITICAL SNS topic"
  event_pattern = jsonencode({
    source      = ["aws.securityhub"]
    detail-type = ["Security Hub Findings - Imported"]
    detail = {
      findings = {
        Severity = {
          Label = ["CRITICAL"]
        }
        Workflow = {
          Status = ["NEW"]
        }
      }
    }
  })
  tags = merge(var.common_tags, { Name = "${var.name_prefix}-securityhub-critical" })
}

resource "aws_cloudwatch_event_target" "securityhub_critical_sns" {
  rule      = aws_cloudwatch_event_rule.securityhub_critical.name
  target_id = "SecurityHubCriticalSNS"
  arn       = module.sns_critical.topic_arn
}
