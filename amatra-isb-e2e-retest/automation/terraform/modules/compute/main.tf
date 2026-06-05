#------------------------------------------------------------------------------
# Compute Module - Tier 2 Solution Module
# Composes Lambda functions and ECR for the 17-function platform
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# ECR Repository for agent Docker image (eof-tools + ~30 Python modules)
#------------------------------------------------------------------------------
module "ecr" {
  source = "../aws/ecr"

  repository_name = var.compute.ecr_repository_name
  common_tags     = var.common_tags
}

#------------------------------------------------------------------------------
# API Route Handlers (10 non-generation routes)
#------------------------------------------------------------------------------
module "lambda_api_handler" {
  source = "../aws/lambda"

  name_prefix          = var.name_prefix
  function_name_suffix = "api-handler"
  description          = "EO Framework API route handler (non-generation routes)"
  environment          = var.environment
  runtime              = var.compute.lambda_runtime
  handler              = "handler.lambda_handler"
  package_type         = "Zip"
  memory_mb            = var.compute.api_handler_memory_mb
  timeout_seconds      = var.compute.api_handler_timeout_seconds
  architecture         = var.compute.lambda_architecture
  xray_tracing_mode    = var.compute.xray_tracing
  log_retention_days   = var.log_retention_days
  vpc_id               = var.vpc_id
  subnet_ids           = var.private_subnet_ids

  environment_variables = {
    ENVIRONMENT          = var.environment
    LOG_LEVEL            = var.log_level
    REGION               = var.region
    USERS_TABLE          = var.users_table_name
    SOLUTIONS_TABLE      = var.solutions_table_name
    QUOTAS_TABLE         = var.quotas_table_name
    AUDIT_EVENTS_TABLE   = var.audit_events_table_name
    ARTIFACT_BUCKET      = var.artifact_bucket_name
    QUOTA_PER_USER       = tostring(var.quota_per_user_monthly)
    QUOTA_GLOBAL         = tostring(var.quota_global_monthly)
  }

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = var.dynamodb_table_arns
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.artifact_bucket_arn,
          "${var.artifact_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# Solution Generation Initiator Lambda
#------------------------------------------------------------------------------
module "lambda_generation_initiator" {
  source = "../aws/lambda"

  name_prefix          = var.name_prefix
  function_name_suffix = "generation-initiator"
  description          = "EO Framework solution generation initiator — triggers five-agent graph"
  environment          = var.environment
  runtime              = var.compute.lambda_runtime
  handler              = "initiator.lambda_handler"
  package_type         = "Zip"
  memory_mb            = var.compute.generation_initiator_memory_mb
  timeout_seconds      = var.compute.generation_initiator_timeout_seconds
  architecture         = var.compute.lambda_architecture
  xray_tracing_mode    = var.compute.xray_tracing
  log_retention_days   = var.log_retention_days
  vpc_id               = var.vpc_id
  subnet_ids           = var.private_subnet_ids

  environment_variables = {
    ENVIRONMENT        = var.environment
    LOG_LEVEL          = var.log_level
    REGION             = var.region
    SOLUTIONS_TABLE    = var.solutions_table_name
    BEDROCK_REGION     = var.bedrock_region
    PRIMARY_MODEL_ID   = var.bedrock_primary_model_id
  }

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = var.dynamodb_table_arns
      },
      {
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# Agent Trigger Lambdas (5 functions — container image from ECR)
#------------------------------------------------------------------------------
module "lambda_agent_input_validator" {
  source = "../aws/lambda"

  name_prefix          = var.name_prefix
  function_name_suffix = "agent-input-validator"
  description          = "EO Framework Agent 0 — Input Validator trigger"
  environment          = var.environment
  package_type         = "Image"
  image_uri            = var.compute.ecr_agent_image_uri
  memory_mb            = var.compute.agent_trigger_memory_mb
  timeout_seconds      = var.compute.agent_trigger_timeout_seconds
  architecture         = var.compute.lambda_architecture
  xray_tracing_mode    = var.compute.xray_tracing
  log_retention_days   = var.log_retention_days
  vpc_id               = var.vpc_id
  subnet_ids           = var.private_subnet_ids

  environment_variables = {
    ENVIRONMENT      = var.environment
    LOG_LEVEL        = var.log_level
    AGENT_NAME       = "input-validator"
    BEDROCK_REGION   = var.bedrock_region
    SOLUTIONS_TABLE  = var.solutions_table_name
    ARTIFACT_BUCKET  = var.artifact_bucket_name
    GUIDANCE_BUCKET  = var.guidance_bucket_name
  }

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = var.dynamodb_table_arns
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          var.artifact_bucket_arn,
          "${var.artifact_bucket_arn}/*",
          var.guidance_bucket_arn,
          "${var.guidance_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })

  common_tags = var.common_tags
}

module "lambda_agent_presales_generator" {
  source = "../aws/lambda"

  name_prefix          = var.name_prefix
  function_name_suffix = "agent-presales-generator"
  description          = "EO Framework Pre-Sales Generator agent trigger"
  environment          = var.environment
  package_type         = "Image"
  image_uri            = var.compute.ecr_agent_image_uri
  memory_mb            = var.compute.agent_trigger_memory_mb
  timeout_seconds      = var.compute.agent_trigger_timeout_seconds
  architecture         = var.compute.lambda_architecture
  xray_tracing_mode    = var.compute.xray_tracing
  log_retention_days   = var.log_retention_days
  vpc_id               = var.vpc_id
  subnet_ids           = var.private_subnet_ids

  environment_variables = {
    ENVIRONMENT     = var.environment
    LOG_LEVEL       = var.log_level
    AGENT_NAME      = "presales-generator"
    BEDROCK_REGION  = var.bedrock_region
    SOLUTIONS_TABLE = var.solutions_table_name
    ARTIFACT_BUCKET = var.artifact_bucket_name
    GUIDANCE_BUCKET = var.guidance_bucket_name
  }

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = var.dynamodb_table_arns
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          var.artifact_bucket_arn, "${var.artifact_bucket_arn}/*",
          var.guidance_bucket_arn, "${var.guidance_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })

  common_tags = var.common_tags
}

module "lambda_agent_delivery_generator" {
  source = "../aws/lambda"

  name_prefix          = var.name_prefix
  function_name_suffix = "agent-delivery-generator"
  description          = "EO Framework Delivery Generator agent trigger"
  environment          = var.environment
  package_type         = "Image"
  image_uri            = var.compute.ecr_agent_image_uri
  memory_mb            = var.compute.agent_trigger_memory_mb
  timeout_seconds      = var.compute.agent_trigger_timeout_seconds
  architecture         = var.compute.lambda_architecture
  xray_tracing_mode    = var.compute.xray_tracing
  log_retention_days   = var.log_retention_days
  vpc_id               = var.vpc_id
  subnet_ids           = var.private_subnet_ids

  environment_variables = {
    ENVIRONMENT     = var.environment
    LOG_LEVEL       = var.log_level
    AGENT_NAME      = "delivery-generator"
    BEDROCK_REGION  = var.bedrock_region
    SOLUTIONS_TABLE = var.solutions_table_name
    ARTIFACT_BUCKET = var.artifact_bucket_name
    GUIDANCE_BUCKET = var.guidance_bucket_name
  }

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = var.dynamodb_table_arns
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          var.artifact_bucket_arn, "${var.artifact_bucket_arn}/*",
          var.guidance_bucket_arn, "${var.guidance_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })

  common_tags = var.common_tags
}

module "lambda_agent_code_generator" {
  source = "../aws/lambda"

  name_prefix          = var.name_prefix
  function_name_suffix = "agent-code-generator"
  description          = "EO Framework Code Generator agent trigger (Terraform IaC bundle)"
  environment          = var.environment
  package_type         = "Image"
  image_uri            = var.compute.ecr_agent_image_uri
  memory_mb            = var.compute.agent_trigger_memory_mb
  timeout_seconds      = var.compute.agent_trigger_timeout_seconds
  architecture         = var.compute.lambda_architecture
  xray_tracing_mode    = var.compute.xray_tracing
  log_retention_days   = var.log_retention_days
  vpc_id               = var.vpc_id
  subnet_ids           = var.private_subnet_ids

  environment_variables = {
    ENVIRONMENT     = var.environment
    LOG_LEVEL       = var.log_level
    AGENT_NAME      = "code-generator"
    BEDROCK_REGION  = var.bedrock_region
    SOLUTIONS_TABLE = var.solutions_table_name
    ARTIFACT_BUCKET = var.artifact_bucket_name
    GUIDANCE_BUCKET = var.guidance_bucket_name
  }

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = var.dynamodb_table_arns
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          var.artifact_bucket_arn, "${var.artifact_bucket_arn}/*",
          var.guidance_bucket_arn, "${var.guidance_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })

  common_tags = var.common_tags
}

module "lambda_agent_eo_validator" {
  source = "../aws/lambda"

  name_prefix          = var.name_prefix
  function_name_suffix = "agent-eo-validator"
  description          = "EO Framework EO Validator agent trigger (format-check + quality scoring)"
  environment          = var.environment
  package_type         = "Image"
  image_uri            = var.compute.ecr_agent_image_uri
  memory_mb            = var.compute.agent_trigger_memory_mb
  timeout_seconds      = var.compute.agent_trigger_timeout_seconds
  architecture         = var.compute.lambda_architecture
  xray_tracing_mode    = var.compute.xray_tracing
  log_retention_days   = var.log_retention_days
  vpc_id               = var.vpc_id
  subnet_ids           = var.private_subnet_ids

  environment_variables = {
    ENVIRONMENT        = var.environment
    LOG_LEVEL          = var.log_level
    AGENT_NAME         = "eo-validator"
    BEDROCK_REGION     = var.bedrock_region
    VALIDATOR_MODEL_ID = var.bedrock_validator_model_id
    MAX_RETRIES        = tostring(var.max_retries_per_artifact)
    SOLUTIONS_TABLE    = var.solutions_table_name
    ARTIFACT_BUCKET    = var.artifact_bucket_name
    GITHUB_SECRET_ARN  = var.github_secret_arn
  }

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = var.dynamodb_table_arns
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          var.artifact_bucket_arn, "${var.artifact_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# Cognito Post-Confirmation Trigger Lambda
#------------------------------------------------------------------------------
module "lambda_cognito_trigger" {
  source = "../aws/lambda"

  name_prefix          = var.name_prefix
  function_name_suffix = "cognito-post-confirmation"
  description          = "Cognito post-confirmation trigger — writes user profile to DynamoDB"
  environment          = var.environment
  runtime              = var.compute.lambda_runtime
  handler              = "cognito_trigger.lambda_handler"
  package_type         = "Zip"
  memory_mb            = var.compute.cognito_trigger_memory_mb
  timeout_seconds      = var.compute.cognito_trigger_timeout_seconds
  architecture         = var.compute.lambda_architecture
  xray_tracing_mode    = var.compute.xray_tracing
  log_retention_days   = var.log_retention_days
  vpc_id               = var.vpc_id
  subnet_ids           = var.private_subnet_ids

  environment_variables = {
    ENVIRONMENT   = var.environment
    LOG_LEVEL     = var.log_level
    USERS_TABLE   = var.users_table_name
  }

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = var.dynamodb_table_arns
      },
      {
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# GitHub Push Lambda
#------------------------------------------------------------------------------
module "lambda_github_push" {
  source = "../aws/lambda"

  name_prefix          = var.name_prefix
  function_name_suffix = "github-push"
  description          = "EO Framework GitHub push Lambda — commits artifacts to repository"
  environment          = var.environment
  runtime              = var.compute.lambda_runtime
  handler              = "github_push.lambda_handler"
  package_type         = "Zip"
  memory_mb            = var.compute.github_push_memory_mb
  timeout_seconds      = var.compute.github_push_timeout_seconds
  architecture         = var.compute.lambda_architecture
  xray_tracing_mode    = var.compute.xray_tracing
  log_retention_days   = var.log_retention_days
  vpc_id               = var.vpc_id
  subnet_ids           = var.private_subnet_ids

  environment_variables = {
    ENVIRONMENT       = var.environment
    LOG_LEVEL         = var.log_level
    ARTIFACT_BUCKET   = var.artifact_bucket_name
    SOLUTIONS_TABLE   = var.solutions_table_name
    AUDIT_TABLE       = var.audit_events_table_name
    DLQ_URL           = var.github_dlq_url
    GITHUB_SECRET_ARN = var.github_secret_arn
    PUSH_RETRY_COUNT  = tostring(var.github_push_retry_count)
  }

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [var.github_secret_arn]
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          var.artifact_bucket_arn,
          "${var.artifact_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = var.dynamodb_table_arns
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = [var.github_dlq_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })

  common_tags = var.common_tags
}
