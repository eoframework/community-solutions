#------------------------------------------------------------------------------
# Monitoring Module (Tier 2) - CloudWatch Dashboards + Alarms + SNS
# Calls: aws/cloudwatch
#------------------------------------------------------------------------------

module "cloudwatch" {
  source = "../aws/cloudwatch"

  name_prefix               = var.name_prefix
  classifier_function_name  = var.classifier_function_name
  recommender_function_name = var.recommender_function_name
  autotagger_function_name  = var.autotagger_function_name
  autotagger_dlq_name       = var.autotagger_dlq_name
  api_name                  = var.api_name
  api_stage                 = var.api_stage
  catalog_table_name        = var.catalog_table_name

  lambda_error_threshold         = var.lambda_error_threshold
  apigw_p95_latency_threshold_ms = var.apigw_p95_latency_threshold_ms
  apigw_5xx_threshold            = var.apigw_5xx_threshold
  dlq_depth_threshold            = var.dlq_depth_threshold
  dynamodb_throttle_threshold    = var.dynamodb_throttle_threshold

  operations_dashboard_name = var.operations_dashboard_name
  cost_dashboard_name       = var.cost_dashboard_name

  common_tags = var.common_tags
}
