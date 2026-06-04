#------------------------------------------------------------------------------
# Tier 2: Monitoring Module
# Composes: SNS topic + CloudWatch dashboards + Synthetic Canary + Alarms
# SNS topic and dashboards from this module; alarms for cross-module metrics
# are in the INTEGRATIONS section of each environment's main.tf
#------------------------------------------------------------------------------

module "sns" {
  source = "../aws/sns"

  name_prefix    = var.name_prefix
  sns_topic_name = var.sns_topic_name
  common_tags    = var.common_tags
}

module "cloudwatch_dashboards" {
  source = "../aws/cloudwatch"

  name_prefix                 = var.name_prefix
  dashboard_platform_health   = var.dashboard_platform_health
  dashboard_throughput        = var.dashboard_throughput
  dashboard_cost_telemetry    = var.dashboard_cost_telemetry
  dashboard_quota_utilisation = var.dashboard_quota_utilisation
  aws_region                  = var.aws_region
  common_tags                 = var.common_tags
}
