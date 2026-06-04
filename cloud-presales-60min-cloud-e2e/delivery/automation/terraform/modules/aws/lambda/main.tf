#------------------------------------------------------------------------------
# Tier 1: AWS Lambda — All platform route handlers and Cognito trigger
# Functions use placeholder ZIP archives (deployed by CI/CD pipeline)
#------------------------------------------------------------------------------

locals {
  # Placeholder archive allows terraform validate to succeed without real code
  placeholder_filename = "${path.module}/placeholder.zip"
}

# Create a minimal placeholder zip for validation (real code deployed via CI/CD)
data "archive_file" "placeholder" {
  type        = "zip"
  output_path = local.placeholder_filename

  source {
    content  = "# Placeholder - deployed by CI/CD pipeline"
    filename = "handler.py"
  }
}

#------------------------------------------------------------------------------
# Solution Create Lambda — accepts generation requests, enforces quotas
#------------------------------------------------------------------------------
resource "aws_lambda_function" "solution_create" {
  function_name    = "${var.name_prefix}-lambda-solution-create"
  description      = "Accept solution generation requests; enforce per-user and global quotas; invoke AgentCore Runtime"
  role             = var.solution_create_role_arn
  runtime          = var.lambda_runtime
  handler          = "handler.lambda_handler"
  memory_size      = var.solution_create_memory_mb
  timeout          = var.solution_create_timeout_seconds
  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  reserved_concurrent_executions = var.solution_create_concurrency_limit

  tracing_config {
    mode = var.xray_tracing_enabled ? "Active" : "PassThrough"
  }

  environment {
    variables = {
      LOG_LEVEL                          = var.log_level
      APPLICATION_NAME                   = var.application_name
      APPLICATION_VERSION                = var.application_version
      AWS_REGION_NAME                    = var.aws_region
      BEDROCK_GENERATION_MODEL_ID        = var.bedrock_generation_model_id
      BEDROCK_VALIDATION_MODEL_ID        = var.bedrock_validation_model_id
      BEDROCK_MAX_RETRIES                = tostring(var.bedrock_max_retries)
      BEDROCK_RETRY_INITIAL_DELAY_MS     = tostring(var.bedrock_retry_initial_delay_ms)
      USERS_TABLE_NAME                   = var.users_table_name
      SOLUTIONS_TABLE_NAME               = var.solutions_table_name
      GLOBAL_QUOTA_TABLE_NAME            = var.global_quota_table_name
      ARTIFACTS_BUCKET_NAME              = var.artifacts_bucket_name
      ARTIFACTS_PREFIX_RAW               = var.artifacts_prefix_raw
      USER_MONTHLY_SOLUTION_LIMIT        = tostring(var.user_monthly_solution_limit)
      GLOBAL_MONTHLY_SOLUTION_LIMIT      = tostring(var.global_monthly_solution_limit)
      SSM_S3_ARTIFACTS_BUCKET_PARAM      = var.ssm_s3_artifacts_bucket_param
      SSM_DYNAMODB_SOLUTIONS_TABLE_PARAM = var.ssm_dynamodb_solutions_table_param
    }
  }

  tags = merge(var.common_tags, { FunctionPurpose = "solution-create" })
}

resource "aws_cloudwatch_log_group" "solution_create" {
  name              = "/aws/lambda/${aws_lambda_function.solution_create.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

# Provisioned concurrency alias (prod/DR only — value 0 = no provisioned concurrency in test)
resource "aws_lambda_alias" "solution_create_live" {
  name             = "live"
  description      = "Live alias for blue-green deployment"
  function_name    = aws_lambda_function.solution_create.function_name
  function_version = "$LATEST"
}

resource "aws_lambda_provisioned_concurrency_config" "solution_create" {
  count                             = var.solution_create_provisioned_concurrency > 0 ? 1 : 0
  function_name                     = aws_lambda_function.solution_create.function_name
  qualifier                         = aws_lambda_alias.solution_create_live.name
  provisioned_concurrent_executions = var.solution_create_provisioned_concurrency
}

#------------------------------------------------------------------------------
# Solution Status Lambda — return status and per-phase token usage
#------------------------------------------------------------------------------
resource "aws_lambda_function" "status" {
  function_name    = "${var.name_prefix}-lambda-status"
  description      = "Return solution generation status and per-phase token usage"
  role             = var.status_role_arn
  runtime          = var.lambda_runtime
  handler          = "handler.lambda_handler"
  memory_size      = var.status_memory_mb
  timeout          = var.status_timeout_seconds
  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  tracing_config {
    mode = var.xray_tracing_enabled ? "Active" : "PassThrough"
  }

  environment {
    variables = {
      LOG_LEVEL            = var.log_level
      APPLICATION_NAME     = var.application_name
      SOLUTIONS_TABLE_NAME = var.solutions_table_name
      AWS_REGION_NAME      = var.aws_region
    }
  }

  tags = merge(var.common_tags, { FunctionPurpose = "solution-status" })
}

resource "aws_cloudwatch_log_group" "status" {
  name              = "/aws/lambda/${aws_lambda_function.status.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

#------------------------------------------------------------------------------
# Artifact Fetch Lambda — generate S3 presigned URLs for artifact download
#------------------------------------------------------------------------------
resource "aws_lambda_function" "artifact_fetch" {
  function_name    = "${var.name_prefix}-lambda-artifact-fetch"
  description      = "Generate presigned S3 URLs for authenticated artifact downloads"
  role             = var.artifact_fetch_role_arn
  runtime          = var.lambda_runtime
  handler          = "handler.lambda_handler"
  memory_size      = var.artifact_fetch_memory_mb
  timeout          = var.artifact_fetch_timeout_seconds
  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  tracing_config {
    mode = var.xray_tracing_enabled ? "Active" : "PassThrough"
  }

  environment {
    variables = {
      LOG_LEVEL             = var.log_level
      APPLICATION_NAME      = var.application_name
      ARTIFACTS_BUCKET_NAME = var.artifacts_bucket_name
      SOLUTIONS_TABLE_NAME  = var.solutions_table_name
      AWS_REGION_NAME       = var.aws_region
    }
  }

  tags = merge(var.common_tags, { FunctionPurpose = "artifact-fetch" })
}

resource "aws_cloudwatch_log_group" "artifact_fetch" {
  name              = "/aws/lambda/${aws_lambda_function.artifact_fetch.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

#------------------------------------------------------------------------------
# Admin Usage Lambda — aggregate token usage and platform metrics (admin only)
#------------------------------------------------------------------------------
resource "aws_lambda_function" "admin_usage" {
  function_name    = "${var.name_prefix}-lambda-admin-usage"
  description      = "Return aggregate per-phase token usage and platform throughput metrics (admin group only)"
  role             = var.admin_usage_role_arn
  runtime          = var.lambda_runtime
  handler          = "handler.lambda_handler"
  memory_size      = var.admin_usage_memory_mb
  timeout          = var.admin_usage_timeout_seconds
  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  tracing_config {
    mode = var.xray_tracing_enabled ? "Active" : "PassThrough"
  }

  environment {
    variables = {
      LOG_LEVEL               = var.log_level
      APPLICATION_NAME        = var.application_name
      SOLUTIONS_TABLE_NAME    = var.solutions_table_name
      GLOBAL_QUOTA_TABLE_NAME = var.global_quota_table_name
      USERS_TABLE_NAME        = var.users_table_name
      AWS_REGION_NAME         = var.aws_region
    }
  }

  tags = merge(var.common_tags, { FunctionPurpose = "admin-usage" })
}

resource "aws_cloudwatch_log_group" "admin_usage" {
  name              = "/aws/lambda/${aws_lambda_function.admin_usage.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

#------------------------------------------------------------------------------
# GitHub Integration Lambda — commit artifact bundle to GitHub repository
#------------------------------------------------------------------------------
resource "aws_lambda_function" "github_integration" {
  function_name    = "${var.name_prefix}-lambda-github-integration"
  description      = "Commit generated artifact bundle to GitHub repository via PAT-based pipeline"
  role             = var.github_integration_role_arn
  runtime          = var.lambda_runtime
  handler          = "handler.lambda_handler"
  memory_size      = var.github_integration_memory_mb
  timeout          = var.github_integration_timeout_seconds
  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  reserved_concurrent_executions = var.github_integration_concurrency_limit

  tracing_config {
    mode = var.xray_tracing_enabled ? "Active" : "PassThrough"
  }

  environment {
    variables = {
      LOG_LEVEL                  = var.log_level
      APPLICATION_NAME           = var.application_name
      GITHUB_PAT_SECRET_NAME     = var.github_pat_secret_name
      GITHUB_REPOSITORY_URL      = var.github_repository_url
      GITHUB_COMMIT_RETRY_COUNT  = tostring(var.github_commit_retry_count)
      GITHUB_BRANCH              = var.github_branch
      ARTIFACTS_BUCKET_NAME      = var.artifacts_bucket_name
      SOLUTIONS_TABLE_NAME       = var.solutions_table_name
      AWS_REGION_NAME            = var.aws_region
    }
  }

  tags = merge(var.common_tags, { FunctionPurpose = "github-integration" })
}

resource "aws_cloudwatch_log_group" "github_integration" {
  name              = "/aws/lambda/${aws_lambda_function.github_integration.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

#------------------------------------------------------------------------------
# Post-Confirmation Lambda — Cognito trigger; writes user profile + seeds quota
#------------------------------------------------------------------------------
resource "aws_lambda_function" "post_confirmation" {
  function_name    = "${var.name_prefix}-lambda-post-confirmation"
  description      = "Cognito post-confirmation trigger: write user profile and seed quota counter in DynamoDB"
  role             = var.post_confirmation_role_arn
  runtime          = var.lambda_runtime
  handler          = "handler.lambda_handler"
  memory_size      = var.post_confirmation_memory_mb
  timeout          = var.post_confirmation_timeout_seconds
  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  tracing_config {
    mode = var.xray_tracing_enabled ? "Active" : "PassThrough"
  }

  environment {
    variables = {
      LOG_LEVEL        = var.log_level
      APPLICATION_NAME = var.application_name
      USERS_TABLE_NAME = var.users_table_name
      AWS_REGION_NAME  = var.aws_region
    }
  }

  tags = merge(var.common_tags, { FunctionPurpose = "post-confirmation" })
}

resource "aws_cloudwatch_log_group" "post_confirmation" {
  name              = "/aws/lambda/${aws_lambda_function.post_confirmation.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}
