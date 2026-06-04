#------------------------------------------------------------------------------
# Tier 2 — API capability module
# Composes: aws/lambda (all route handlers), aws/api-gateway
#------------------------------------------------------------------------------

data "aws_region" "current" {}

# CloudWatch Log Group for API Gateway access logs
resource "aws_cloudwatch_log_group" "api_access_logs" {
  name              = "/amatra/${var.environment}/apigw-access-logs"
  retention_in_days = var.monitoring.log_retention_days
  tags              = var.common_tags
}

#------------------------------------------------------------------------------
# Lambda Route Handlers — Tier 1 modules
#------------------------------------------------------------------------------

module "lambda_solution_create" {
  source          = "../aws/lambda"
  function_name   = "${var.name_prefix}-lambda-solution-create"
  runtime         = var.compute.lambda_runtime
  memory_mb       = var.compute.solution_create_memory_mb
  timeout_seconds = var.compute.solution_create_timeout_seconds
  reserved_concurrency      = var.compute.solution_create_concurrency_limit
  provisioned_concurrency   = var.compute.solution_create_provisioned_concurrency
  xray_tracing_enabled      = var.monitoring.xray_tracing_enabled
  log_retention_days        = var.monitoring.log_retention_days
  environment_variables = {
    ENVIRONMENT                     = var.environment
    LOG_LEVEL                       = var.application.log_level
    APPLICATION_NAME                = var.application.name
    APPLICATION_VERSION             = var.application.version
    USERS_TABLE_NAME                = var.database.users_table_name
    SOLUTIONS_TABLE_NAME            = var.database.solutions_table_name
    GLOBAL_QUOTA_TABLE_NAME         = var.database.global_quota_table_name
    USER_MONTHLY_SOLUTION_LIMIT     = tostring(var.quota.user_monthly_solution_limit)
    GLOBAL_MONTHLY_SOLUTION_LIMIT   = tostring(var.quota.global_monthly_solution_limit)
    BEDROCK_GENERATION_MODEL_ID     = var.integration.bedrock_generation_model_id
    BEDROCK_VALIDATION_MODEL_ID     = var.integration.bedrock_validation_model_id
    BEDROCK_MAX_RETRIES             = tostring(var.integration.bedrock_max_retries_per_artifact)
    SSM_ARTIFACTS_BUCKET_PARAM      = var.operations.ssm_s3_artifacts_bucket_param
    SSM_SOLUTIONS_TABLE_PARAM       = var.operations.ssm_dynamodb_solutions_table_param
  }
  additional_policy_statements = [
    {
      Effect   = "Allow"
      Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:ConditionCheckItem"]
      Resource = [
        "arn:aws:dynamodb:*:*:table/${var.database.users_table_name}",
        "arn:aws:dynamodb:*:*:table/${var.database.solutions_table_name}",
        "arn:aws:dynamodb:*:*:table/${var.database.global_quota_table_name}"
      ]
    },
    {
      Effect   = "Allow"
      Action   = ["bedrock:InvokeModel"]
      Resource = [
        "arn:aws:bedrock:*::foundation-model/${var.integration.bedrock_generation_model_id}",
        "arn:aws:bedrock:*::foundation-model/${var.integration.bedrock_validation_model_id}"
      ]
    },
    {
      Effect   = "Allow"
      Action   = ["ssm:GetParameter"]
      Resource = [
        "arn:aws:ssm:*:*:parameter${var.operations.ssm_s3_artifacts_bucket_param}",
        "arn:aws:ssm:*:*:parameter${var.operations.ssm_dynamodb_solutions_table_param}"
      ]
    }
  ]
  common_tags = var.common_tags
}

module "lambda_solution_status" {
  source          = "../aws/lambda"
  function_name   = "${var.name_prefix}-lambda-solution-status"
  runtime         = var.compute.lambda_runtime
  memory_mb       = var.compute.status_memory_mb
  timeout_seconds = var.compute.status_timeout_seconds
  xray_tracing_enabled = var.monitoring.xray_tracing_enabled
  log_retention_days   = var.monitoring.log_retention_days
  environment_variables = {
    ENVIRONMENT          = var.environment
    LOG_LEVEL            = var.application.log_level
    SOLUTIONS_TABLE_NAME = var.database.solutions_table_name
    USERS_TABLE_NAME     = var.database.users_table_name
  }
  additional_policy_statements = [
    {
      Effect   = "Allow"
      Action   = ["dynamodb:GetItem", "dynamodb:Query", "dynamodb:DeleteItem"]
      Resource = [
        "arn:aws:dynamodb:*:*:table/${var.database.solutions_table_name}",
        "arn:aws:dynamodb:*:*:table/${var.database.solutions_table_name}/index/*",
        "arn:aws:dynamodb:*:*:table/${var.database.users_table_name}"
      ]
    }
  ]
  common_tags = var.common_tags
}

module "lambda_artifact_fetch" {
  source          = "../aws/lambda"
  function_name   = "${var.name_prefix}-lambda-artifact-fetch"
  runtime         = var.compute.lambda_runtime
  memory_mb       = var.compute.artifact_fetch_memory_mb
  timeout_seconds = var.compute.artifact_fetch_timeout_seconds
  xray_tracing_enabled = var.monitoring.xray_tracing_enabled
  log_retention_days   = var.monitoring.log_retention_days
  environment_variables = {
    ENVIRONMENT          = var.environment
    LOG_LEVEL            = var.application.log_level
    ARTIFACTS_BUCKET     = var.storage.artifacts_bucket_name
    SOLUTIONS_TABLE_NAME = var.database.solutions_table_name
    USERS_TABLE_NAME     = var.database.users_table_name
  }
  additional_policy_statements = [
    {
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "arn:aws:s3:::${var.storage.artifacts_bucket_name}/*"
    },
    {
      Effect   = "Allow"
      Action   = ["dynamodb:GetItem"]
      Resource = [
        "arn:aws:dynamodb:*:*:table/${var.database.solutions_table_name}",
        "arn:aws:dynamodb:*:*:table/${var.database.users_table_name}"
      ]
    }
  ]
  common_tags = var.common_tags
}

module "lambda_admin_usage" {
  source          = "../aws/lambda"
  function_name   = "${var.name_prefix}-lambda-admin-usage"
  runtime         = var.compute.lambda_runtime
  memory_mb       = var.compute.admin_usage_memory_mb
  timeout_seconds = var.compute.admin_usage_timeout_seconds
  xray_tracing_enabled = var.monitoring.xray_tracing_enabled
  log_retention_days   = var.monitoring.log_retention_days
  environment_variables = {
    ENVIRONMENT             = var.environment
    LOG_LEVEL               = var.application.log_level
    SOLUTIONS_TABLE_NAME    = var.database.solutions_table_name
    GLOBAL_QUOTA_TABLE_NAME = var.database.global_quota_table_name
  }
  additional_policy_statements = [
    {
      Effect   = "Allow"
      Action   = ["dynamodb:GetItem", "dynamodb:Query", "dynamodb:Scan", "dynamodb:UpdateItem"]
      Resource = [
        "arn:aws:dynamodb:*:*:table/${var.database.solutions_table_name}",
        "arn:aws:dynamodb:*:*:table/${var.database.solutions_table_name}/index/*",
        "arn:aws:dynamodb:*:*:table/${var.database.global_quota_table_name}"
      ]
    },
    {
      Effect   = "Allow"
      Action   = ["cloudwatch:GetMetricStatistics", "cloudwatch:ListMetrics"]
      Resource = "*"
    }
  ]
  common_tags = var.common_tags
}

module "lambda_github_integration" {
  source          = "../aws/lambda"
  function_name   = "${var.name_prefix}-lambda-github-integration"
  runtime         = var.compute.lambda_runtime
  memory_mb       = var.compute.github_integration_memory_mb
  timeout_seconds = var.compute.github_integration_timeout_seconds
  reserved_concurrency = var.compute.github_integration_concurrency_limit
  xray_tracing_enabled = var.monitoring.xray_tracing_enabled
  log_retention_days   = var.monitoring.log_retention_days
  environment_variables = {
    ENVIRONMENT              = var.environment
    LOG_LEVEL                = var.application.log_level
    GITHUB_REPO_URL          = var.integration.github_repository_url
    GITHUB_BRANCH            = var.integration.github_branch
    GITHUB_PAT_SECRET_NAME   = var.security.github_pat_secret_name
    GITHUB_COMMIT_RETRY_COUNT = tostring(var.integration.github_commit_retry_count)
    ARTIFACTS_BUCKET         = var.storage.artifacts_bucket_name
  }
  additional_policy_statements = [
    {
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = "arn:aws:secretsmanager:*:*:secret:${var.security.github_pat_secret_name}*"
    },
    {
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Resource = [
        "arn:aws:s3:::${var.storage.artifacts_bucket_name}",
        "arn:aws:s3:::${var.storage.artifacts_bucket_name}/*"
      ]
    },
    {
      Effect   = "Allow"
      Action   = ["dynamodb:UpdateItem"]
      Resource = "arn:aws:dynamodb:*:*:table/${var.database.solutions_table_name}"
    }
  ]
  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# API Gateway HTTP API v2 — Tier 1 module
#------------------------------------------------------------------------------

module "api_gateway" {
  source                     = "../aws/api-gateway"
  api_name                   = "${var.name_prefix}-apigw-http-api"
  stage_name                 = var.networking.api_gateway_stage_name
  throttle_burst_limit       = var.networking.api_gateway_throttle_burst_limit
  throttle_rate_limit        = var.networking.api_gateway_throttle_rate_limit
  cognito_user_pool_id       = var.security.cognito_user_pool_name
  cognito_app_client_id      = var.security.cognito_user_pool_name
  aws_region                 = data.aws_region.current.name
  access_log_group_arn       = aws_cloudwatch_log_group.api_access_logs.arn
  solution_create_lambda_arn = module.lambda_solution_create.function_arn
  solution_status_lambda_arn = module.lambda_solution_status.function_arn
  artifact_fetch_lambda_arn  = module.lambda_artifact_fetch.function_arn
  admin_usage_lambda_arn     = module.lambda_admin_usage.function_arn
  common_tags                = var.common_tags
}
