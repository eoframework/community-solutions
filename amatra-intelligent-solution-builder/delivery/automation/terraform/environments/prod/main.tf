#------------------------------------------------------------------------------
# Amatra Agentic Pre-Sales Platform — Production Environment
# Solution: amatra-presales-platform | Region: us-west-2
# Opportunity: OPP-2026-001 | SOW: 12-week delivery engagement
#------------------------------------------------------------------------------

locals {
  environment = "prod"
  name_prefix = "${var.project.solution_name}-${local.environment}"

  common_tags = {
    Solution           = var.project.solution_name
    Environment        = local.environment
    ManagedBy          = "terraform"
    CostCenter         = var.project.opportunity_id
    Owner              = "amatra-engineering"
    DataClassification = "PREDICTif-Confidential"
    Project            = var.project.solution_name
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#===============================================================================
# FOUNDATION — Core infrastructure all other modules depend on
#===============================================================================

# KMS Customer-Managed Key for S3, CloudWatch Logs, and Secrets Manager
module "kms" {
  source = "../../modules/aws/kms"

  name_prefix     = local.name_prefix
  description     = "CMK for Amatra platform S3 artifacts and CloudWatch Logs — Production"
  enable_rotation = true
  common_tags     = local.common_tags
}

# VPC, private subnets (3 AZs), public subnet, NAT Gateway, VPC endpoints
module "networking" {
  source = "../../modules/aws/vpc"

  name_prefix             = local.name_prefix
  vpc_cidr                = var.network.vpc_cidr
  subnet_private_az1_cidr = var.network.subnet_private_az1_cidr
  subnet_private_az2_cidr = var.network.subnet_private_az2_cidr
  subnet_private_az3_cidr = var.network.subnet_private_az3_cidr
  subnet_public_cidr      = var.network.subnet_public_cidr
  nat_gateway_count       = var.network.nat_gateway_count
  vpc_endpoints_enabled   = var.network.vpc_endpoints_enabled
  region                  = var.project.region
  common_tags             = local.common_tags

  depends_on = [module.kms]
}

#===============================================================================
# CORE SOLUTION — Platform identity, data, compute, and AI services
#===============================================================================

# Cognito User Pool — JWT auth, 30-day refresh tokens, post-confirmation trigger
module "cognito" {
  source = "../../modules/aws/cognito"

  name_prefix                = local.name_prefix
  user_pool_name             = var.security.cognito_user_pool_name
  refresh_token_validity     = var.security.cognito_token_refresh_ttl_days
  access_token_validity      = var.security.cognito_access_token_ttl_hours
  mfa_configuration          = var.security.cognito_mfa_enabled ? "ON" : "OPTIONAL"
  common_tags                = local.common_tags

  depends_on = [module.networking]
}

# DynamoDB tables — user profiles, solution state, global quota
module "database" {
  source = "../../modules/aws/dynamodb"

  name_prefix               = local.name_prefix
  table_user_profiles       = var.database.table_user_profiles
  table_solution_state      = var.database.table_solution_state
  table_quota_global        = var.database.table_quota_global
  billing_mode              = var.database.billing_mode
  pitr_enabled              = var.database.pitr_enabled
  solution_state_ttl_days   = var.database.solution_state_ttl_days
  common_tags               = local.common_tags

  depends_on = [module.kms]
}

# S3 artifact bucket — raw MD/CSV and converted DOCX/PPTX/XLSX
module "storage" {
  source = "../../modules/aws/s3"

  name_prefix             = local.name_prefix
  account_id              = data.aws_caller_identity.current.account_id
  kms_key_arn             = module.kms.key_arn
  versioning_enabled      = var.storage.versioning_enabled
  glacier_transition_days = var.storage.glacier_transition_days
  artifact_retention_days = var.project.artifact_retention_days
  enforce_ssl             = var.storage.enforce_ssl
  cloudtrail_enabled      = var.security.cloudtrail_enabled
  cloudtrail_retention_days = var.security.cloudtrail_retention_days
  common_tags             = local.common_tags

  depends_on = [module.kms]
}

# ECR repository for AgentCore agent Docker images with eof-tools
module "ecr" {
  source = "../../modules/aws/ecr"

  name_prefix           = local.name_prefix
  repository_name       = var.compute.ecr_repository_name
  image_retention_count = var.compute.ecr_image_retention_count
  common_tags           = local.common_tags
}

# Secrets Manager secrets — GitHub PAT and Cognito client secret (values from SSM at runtime)
module "secrets" {
  source = "../../modules/aws/secrets-manager"

  name_prefix               = local.name_prefix
  github_pat_secret_name    = var.security.github_pat_secret_name
  cognito_secret_name       = var.security.cognito_secret_name
  kms_key_arn               = module.kms.key_arn
  common_tags               = local.common_tags

  depends_on = [module.kms]
}

# Lambda functions — 11 API routes + post-confirmation + quota-reset + DLQ alarm
module "compute" {
  source = "../../modules/aws/lambda"

  name_prefix                 = local.name_prefix
  memory_mb                   = var.compute.lambda_memory_mb
  timeout_seconds             = var.compute.lambda_timeout_seconds
  reserved_concurrency        = var.compute.lambda_reserved_concurrency
  ecr_repository_url          = module.ecr.repository_url
  vpc_id                      = module.networking.vpc_id
  private_subnet_ids          = module.networking.private_subnet_ids
  kms_key_arn                 = module.kms.key_arn
  table_user_profiles_name    = module.database.table_user_profiles_name
  table_solution_state_name   = module.database.table_solution_state_name
  table_quota_global_name     = module.database.table_quota_global_name
  artifact_bucket_name        = module.storage.artifact_bucket_name
  github_pat_secret_arn       = module.secrets.github_pat_secret_arn
  cognito_user_pool_id        = module.cognito.user_pool_id
  log_level                   = var.application.log_level
  validation_retry_limit      = var.application.validation_retry_limit
  generation_timeout_minutes  = var.application.generation_timeout_minutes
  quota_reset_schedule        = var.operations.quota_reset_schedule
  metrics_namespace           = var.monitoring.metrics_namespace
  common_tags                 = local.common_tags

  depends_on = [module.networking, module.database, module.storage, module.secrets, module.cognito]
}

# API Gateway HTTP API v2 — 11 JWT-protected Lambda routes
module "api_gateway" {
  source = "../../modules/aws/api-gateway"

  name_prefix              = local.name_prefix
  cognito_user_pool_id     = module.cognito.user_pool_id
  cognito_user_pool_arn    = module.cognito.user_pool_arn
  lambda_invoke_arns       = module.compute.lambda_invoke_arns
  lambda_function_names    = module.compute.lambda_function_names
  throttle_rate_limit      = 100
  throttle_burst_limit     = 200
  common_tags              = local.common_tags

  depends_on = [module.compute, module.cognito]
}

# Step Functions state machine — multi-agent orchestration graph
module "stepfunctions" {
  source = "../../modules/aws/step-functions"

  name_prefix                      = local.name_prefix
  execution_timeout_seconds        = var.compute.stepfunctions_execution_timeout_seconds
  lambda_function_arns             = module.compute.lambda_function_arns
  table_solution_state_name        = module.database.table_solution_state_name
  artifact_bucket_name             = module.storage.artifact_bucket_name
  kms_key_arn                      = module.kms.key_arn
  common_tags                      = local.common_tags

  depends_on = [module.compute, module.database]
}

# GuardDuty — threat detection per SOC 2 baseline
module "guardduty" {
  source = "../../modules/aws/guardduty"

  name_prefix = local.name_prefix
  enabled     = var.security.guardduty_enabled
  common_tags = local.common_tags
}

# CloudTrail — data events for S3 and DynamoDB with WORM retention
module "cloudtrail" {
  source = "../../modules/aws/cloudtrail"

  name_prefix          = local.name_prefix
  enabled              = var.security.cloudtrail_enabled
  cloudtrail_bucket    = module.storage.cloudtrail_bucket_name
  kms_key_arn          = module.kms.key_arn
  retention_days       = var.security.cloudtrail_retention_days
  common_tags          = local.common_tags

  depends_on = [module.storage, module.kms]
}

# CodePipeline + CodeBuild — Docker build, ECR push, terraform validate gate
module "cicd" {
  source = "../../modules/aws/codepipeline"

  name_prefix              = local.name_prefix
  codepipeline_name        = var.cicd.codepipeline_name
  codebuild_compute_type   = var.cicd.codebuild_compute_type
  terraform_validate_gate  = var.cicd.terraform_validate_gate
  ecr_repository_url       = module.ecr.repository_url
  ecr_repository_arn       = module.ecr.repository_arn
  kms_key_arn              = module.kms.key_arn
  artifact_bucket_name     = module.storage.artifact_bucket_name
  common_tags              = local.common_tags

  depends_on = [module.ecr, module.storage]
}

#===============================================================================
# OPERATIONS — Monitoring, alarms, dashboards, and best practices
#===============================================================================

# CloudWatch — log groups, dashboards, SNS topic, alarms, custom metrics
module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix                                  = local.name_prefix
  environment                                  = local.environment
  cloudwatch_dashboard_name                    = var.monitoring.cloudwatch_dashboard_name
  log_retention_days                           = var.monitoring.log_retention_days
  metrics_namespace                            = var.monitoring.metrics_namespace
  kms_key_arn                                  = module.kms.key_arn
  lambda_function_names                        = module.compute.lambda_function_names
  stepfunctions_state_machine_arn              = module.stepfunctions.state_machine_arn
  table_user_profiles_name                     = module.database.table_user_profiles_name
  table_quota_global_name                      = module.database.table_quota_global_name
  lambda_error_rate_alarm_threshold            = var.monitoring.lambda_error_rate_alarm_threshold
  stepfunctions_failure_rate_alarm_threshold   = var.monitoring.stepfunctions_failure_rate_alarm_threshold
  bedrock_daily_spend_alarm_pct                = var.monitoring.bedrock_daily_spend_alarm_pct
  token_usage_metric_name                      = var.monitoring.token_usage_metric_name
  monthly_token_budget_millions                = var.bedrock.monthly_token_budget_millions
  common_tags                                  = local.common_tags

  depends_on = [module.kms, module.compute, module.stepfunctions, module.database]
}

#===============================================================================
# INTEGRATIONS — Cross-module wiring that avoids circular dependencies
#===============================================================================

# Wire SNS alarm topic ARN from monitoring back into Lambda environment (SSM parameter pattern)
resource "aws_ssm_parameter" "sns_alarm_topic_arn" {
  name  = "/${var.project.solution_name}/${local.environment}/monitoring/sns_alarm_topic_arn"
  type  = "String"
  value = module.monitoring.sns_topic_arn

  tags = local.common_tags

  depends_on = [module.monitoring]
}

# Wire Step Functions ARN into Lambda environment via SSM
resource "aws_ssm_parameter" "stepfunctions_arn" {
  name  = "/${var.project.solution_name}/${local.environment}/compute/stepfunctions_state_machine_arn"
  type  = "String"
  value = module.stepfunctions.state_machine_arn

  tags = local.common_tags

  depends_on = [module.stepfunctions]
}

# High Lambda error rate alarm (cross-module: compute + monitoring)
resource "aws_cloudwatch_metric_alarm" "lambda_error_rate_high" {
  alarm_name          = "${local.name_prefix}-lambda-error-rate-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = var.monitoring.lambda_error_rate_alarm_threshold
  alarm_description   = "Lambda error rate exceeded ${var.monitoring.lambda_error_rate_alarm_threshold}% — investigate CloudWatch Logs"
  alarm_actions       = [module.monitoring.sns_topic_arn]
  ok_actions          = [module.monitoring.sns_topic_arn]
  treat_missing_data  = "notBreaching"

  tags = local.common_tags

  depends_on = [module.compute, module.monitoring]
}

# Step Functions execution failure alarm (cross-module: stepfunctions + monitoring)
resource "aws_cloudwatch_metric_alarm" "stepfunctions_failure_high" {
  alarm_name          = "${local.name_prefix}-sfn-execution-failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ExecutionsFailed"
  namespace           = "AWS/States"
  period              = 900
  statistic           = "Sum"
  threshold           = var.monitoring.stepfunctions_failure_rate_alarm_threshold
  alarm_description   = "Step Functions execution failures exceeded threshold — check DLQ and agent logs"
  alarm_actions       = [module.monitoring.sns_topic_arn]
  ok_actions          = [module.monitoring.sns_topic_arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    StateMachineArn = module.stepfunctions.state_machine_arn
  }

  tags = local.common_tags

  depends_on = [module.stepfunctions, module.monitoring]
}
