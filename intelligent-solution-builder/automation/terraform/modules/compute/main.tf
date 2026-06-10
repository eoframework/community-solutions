#------------------------------------------------------------------------------
# Tier 2 — Compute Module
# Composes: aws/lambda — all ISB platform Lambda functions
# Functions: api-submit, api-status, api-retrieve, api-admin,
#            orchestrator-start, bedrock-sonnet, bedrock-haiku, artifact-processor
#------------------------------------------------------------------------------

locals {
  # Common IAM policy statements for all Lambda functions
  base_secrets_policy = [
    {
      Sid      = "AllowSecretsManagerRead"
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      Resource = "arn:aws:secretsmanager:${var.aws_region}:*:secret:${var.secret_prefix}/*"
    },
    {
      Sid      = "AllowKMSDecrypt"
      Effect   = "Allow"
      Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
      Resource = var.kms_key_arn
    }
  ]

  dynamodb_read_policy = [
    {
      Sid    = "AllowDynamoDBReadSolutionState"
      Effect = "Allow"
      Action = ["dynamodb:GetItem", "dynamodb:Query", "dynamodb:Scan"]
      Resource = [
        "arn:aws:dynamodb:${var.aws_region}:*:table/${var.solution_state_table_name}",
        "arn:aws:dynamodb:${var.aws_region}:*:table/${var.solution_state_table_name}/index/*",
      ]
    },
    {
      Sid    = "AllowDynamoDBReadUsage"
      Effect = "Allow"
      Action = ["dynamodb:GetItem", "dynamodb:Query", "dynamodb:UpdateItem"]
      Resource = [
        "arn:aws:dynamodb:${var.aws_region}:*:table/${var.usage_tracking_table_name}",
        "arn:aws:dynamodb:${var.aws_region}:*:table/${var.usage_tracking_table_name}/index/*",
      ]
    }
  ]

  dynamodb_write_policy = [
    {
      Sid    = "AllowDynamoDBWriteSolutionState"
      Effect = "Allow"
      Action = ["dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:DeleteItem"]
      Resource = "arn:aws:dynamodb:${var.aws_region}:*:table/${var.solution_state_table_name}"
    }
  ]

  s3_read_policy = [
    {
      Sid    = "AllowS3ReadArtifacts"
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:ListBucket"]
      Resource = [
        "arn:aws:s3:::${var.artifacts_bucket_name}",
        "arn:aws:s3:::${var.artifacts_bucket_name}/*",
        "arn:aws:s3:::${var.templates_bucket_name}",
        "arn:aws:s3:::${var.templates_bucket_name}/*",
      ]
    }
  ]

  s3_write_policy = [
    {
      Sid    = "AllowS3WriteArtifacts"
      Effect = "Allow"
      Action = ["s3:PutObject"]
      Resource = "arn:aws:s3:::${var.artifacts_bucket_name}/*"
    }
  ]

  sqs_send_policy = [
    {
      Sid    = "AllowSQSSend"
      Effect = "Allow"
      Action = ["sqs:SendMessage", "sqs:GetQueueAttributes"]
      Resource = var.job_queue_arn
    }
  ]

  sqs_receive_policy = [
    {
      Sid    = "AllowSQSReceive"
      Effect = "Allow"
      Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      Resource = var.job_queue_arn
    }
  ]

  sfn_start_policy = [
    {
      Sid    = "AllowStepFunctionsStart"
      Effect = "Allow"
      Action = ["states:StartExecution", "states:DescribeExecution"]
      Resource = "arn:aws:states:${var.aws_region}:*:stateMachine:${var.state_machine_name}"
    }
  ]

  sfn_task_callback_policy = [
    {
      Sid    = "AllowStepFunctionsCallback"
      Effect = "Allow"
      Action = ["states:SendTaskSuccess", "states:SendTaskFailure", "states:SendTaskHeartbeat"]
      Resource = "*"
    }
  ]

  bedrock_sonnet_policy = [
    {
      Sid    = "AllowBedrockSonnet"
      Effect = "Allow"
      Action = ["bedrock:InvokeModel"]
      Resource = "arn:aws:bedrock:${var.aws_region}::foundation-model/${var.sonnet_model_id}"
    }
  ]

  bedrock_haiku_policy = [
    {
      Sid    = "AllowBedrockHaiku"
      Effect = "Allow"
      Action = ["bedrock:InvokeModel"]
      Resource = "arn:aws:bedrock:${var.aws_region}::foundation-model/${var.haiku_model_id}"
    }
  ]

  common_env = {
    ENVIRONMENT              = var.environment
    LOG_LEVEL                = var.log_level
    AWS_REGION_NAME          = var.aws_region
    SECRET_PREFIX            = var.secret_prefix
    SOLUTION_STATE_TABLE     = var.solution_state_table_name
    USAGE_TRACKING_TABLE     = var.usage_tracking_table_name
    ARTIFACTS_BUCKET         = var.artifacts_bucket_name
    TEMPLATES_BUCKET         = var.templates_bucket_name
    JOB_QUEUE_URL            = var.job_queue_url
    STATE_MACHINE_NAME       = var.state_machine_name
    SONNET_MODEL_ID          = var.sonnet_model_id
    HAIKU_MODEL_ID           = var.haiku_model_id
    PRESIGNED_URL_TTL        = tostring(var.presigned_url_ttl_seconds)
    PER_USER_MONTHLY_LIMIT   = tostring(var.per_user_monthly_limit)
    GLOBAL_MONTHLY_LIMIT     = tostring(var.global_monthly_limit)
  }
}

# Placeholder zip for Lambda functions — replaced by CI/CD pipeline
data "archive_file" "placeholder" {
  type        = "zip"
  output_path = "${path.module}/placeholder.zip"

  source {
    content  = "# Placeholder — replaced by CI/CD deployment\ndef lambda_handler(event, context): return {'statusCode': 200}"
    filename = "handler.py"
  }
}

#------------------------------------------------------------------------------
# API Handler — Submit Brief (isb-api-submit)
#------------------------------------------------------------------------------
module "api_submit" {
  source = "../aws/lambda"

  function_name           = "isb-api-submit-${var.environment}"
  runtime                 = var.runtime
  memory_size             = var.api_submit_memory
  timeout                 = var.api_submit_timeout
  alias_name              = var.lambda_alias
  provisioned_concurrency = var.api_submit_provisioned
  log_retention_days      = var.log_retention_days
  kms_key_arn             = var.kms_key_arn
  filename                = data.archive_file.placeholder.output_path
  source_code_hash        = data.archive_file.placeholder.output_base64sha256
  common_tags             = var.common_tags

  environment_variables = merge(local.common_env, {
    FUNCTION_PURPOSE = "api-submit"
  })

  additional_policy_statements = concat(
    local.base_secrets_policy,
    local.dynamodb_read_policy,
    local.dynamodb_write_policy,
    local.sqs_send_policy
  )
}

#------------------------------------------------------------------------------
# API Handler — Poll Status (isb-api-status)
#------------------------------------------------------------------------------
module "api_status" {
  source = "../aws/lambda"

  function_name           = "isb-api-status-${var.environment}"
  runtime                 = var.runtime
  memory_size             = var.api_status_memory
  timeout                 = var.api_status_timeout
  alias_name              = var.lambda_alias
  provisioned_concurrency = var.api_status_provisioned
  log_retention_days      = var.log_retention_days
  kms_key_arn             = var.kms_key_arn
  filename                = data.archive_file.placeholder.output_path
  source_code_hash        = data.archive_file.placeholder.output_base64sha256
  common_tags             = var.common_tags

  environment_variables = merge(local.common_env, {
    FUNCTION_PURPOSE = "api-status"
  })

  additional_policy_statements = concat(
    local.base_secrets_policy,
    local.dynamodb_read_policy
  )
}

#------------------------------------------------------------------------------
# API Handler — Retrieve Artifact (isb-api-retrieve)
#------------------------------------------------------------------------------
module "api_retrieve" {
  source = "../aws/lambda"

  function_name           = "isb-api-retrieve-${var.environment}"
  runtime                 = var.runtime
  memory_size             = var.api_retrieve_memory
  timeout                 = var.api_retrieve_timeout
  alias_name              = var.lambda_alias
  provisioned_concurrency = var.api_retrieve_provisioned
  log_retention_days      = var.log_retention_days
  kms_key_arn             = var.kms_key_arn
  filename                = data.archive_file.placeholder.output_path
  source_code_hash        = data.archive_file.placeholder.output_base64sha256
  common_tags             = var.common_tags

  environment_variables = merge(local.common_env, {
    FUNCTION_PURPOSE = "api-retrieve"
  })

  additional_policy_statements = concat(
    local.base_secrets_policy,
    local.dynamodb_read_policy,
    local.s3_read_policy
  )
}

#------------------------------------------------------------------------------
# API Handler — Admin Controls (isb-api-admin)
#------------------------------------------------------------------------------
module "api_admin" {
  source = "../aws/lambda"

  function_name           = "isb-api-admin-${var.environment}"
  runtime                 = var.runtime
  memory_size             = var.api_admin_memory
  timeout                 = var.api_admin_timeout
  alias_name              = var.lambda_alias
  provisioned_concurrency = var.api_admin_provisioned
  log_retention_days      = var.log_retention_days
  kms_key_arn             = var.kms_key_arn
  filename                = data.archive_file.placeholder.output_path
  source_code_hash        = data.archive_file.placeholder.output_base64sha256
  common_tags             = var.common_tags

  environment_variables = merge(local.common_env, {
    FUNCTION_PURPOSE = "api-admin"
  })

  additional_policy_statements = concat(
    local.base_secrets_policy,
    local.dynamodb_read_policy,
    local.dynamodb_write_policy
  )
}

#------------------------------------------------------------------------------
# Step Functions Initiator / Orchestrator (isb-orchestrator-start)
#------------------------------------------------------------------------------
module "orchestrator_start" {
  source = "../aws/lambda"

  function_name      = "isb-orchestrator-start-${var.environment}"
  runtime            = var.runtime
  memory_size        = var.orchestrator_memory
  timeout            = var.orchestrator_timeout
  alias_name         = var.lambda_alias
  log_retention_days = var.log_retention_days
  kms_key_arn        = var.kms_key_arn
  filename           = data.archive_file.placeholder.output_path
  source_code_hash   = data.archive_file.placeholder.output_base64sha256
  common_tags        = var.common_tags

  environment_variables = merge(local.common_env, {
    FUNCTION_PURPOSE = "orchestrator-start"
  })

  additional_policy_statements = concat(
    local.base_secrets_policy,
    local.dynamodb_read_policy,
    local.dynamodb_write_policy,
    local.sqs_receive_policy,
    local.sfn_start_policy,
    local.s3_read_policy
  )
}

#------------------------------------------------------------------------------
# Bedrock Invoker — Claude 3 Sonnet (isb-bedrock-sonnet)
#------------------------------------------------------------------------------
module "bedrock_sonnet" {
  source = "../aws/lambda"

  function_name      = "isb-bedrock-sonnet-${var.environment}"
  runtime            = var.runtime
  memory_size        = var.bedrock_sonnet_memory
  timeout            = var.bedrock_sonnet_timeout
  alias_name         = var.lambda_alias
  log_retention_days = var.log_retention_days
  kms_key_arn        = var.kms_key_arn
  filename           = data.archive_file.placeholder.output_path
  source_code_hash   = data.archive_file.placeholder.output_base64sha256
  common_tags        = var.common_tags

  environment_variables = merge(local.common_env, {
    FUNCTION_PURPOSE = "bedrock-sonnet"
  })

  additional_policy_statements = concat(
    local.base_secrets_policy,
    local.dynamodb_write_policy,
    local.s3_read_policy,
    local.s3_write_policy,
    local.sfn_task_callback_policy,
    local.bedrock_sonnet_policy
  )
}

#------------------------------------------------------------------------------
# Bedrock Invoker — Claude 3 Haiku (isb-bedrock-haiku)
#------------------------------------------------------------------------------
module "bedrock_haiku" {
  source = "../aws/lambda"

  function_name      = "isb-bedrock-haiku-${var.environment}"
  runtime            = var.runtime
  memory_size        = var.bedrock_haiku_memory
  timeout            = var.bedrock_haiku_timeout
  alias_name         = var.lambda_alias
  log_retention_days = var.log_retention_days
  kms_key_arn        = var.kms_key_arn
  filename           = data.archive_file.placeholder.output_path
  source_code_hash   = data.archive_file.placeholder.output_base64sha256
  common_tags        = var.common_tags

  environment_variables = merge(local.common_env, {
    FUNCTION_PURPOSE = "bedrock-haiku"
  })

  additional_policy_statements = concat(
    local.base_secrets_policy,
    local.dynamodb_write_policy,
    local.s3_read_policy,
    local.s3_write_policy,
    local.sfn_task_callback_policy,
    local.bedrock_haiku_policy
  )
}

#------------------------------------------------------------------------------
# Artifact Processor / QA Scoring (isb-artifact-processor)
#------------------------------------------------------------------------------
module "artifact_processor" {
  source = "../aws/lambda"

  function_name      = "isb-artifact-processor-${var.environment}"
  runtime            = var.runtime
  memory_size        = var.artifact_processor_memory
  timeout            = var.artifact_processor_timeout
  alias_name         = var.lambda_alias
  log_retention_days = var.log_retention_days
  kms_key_arn        = var.kms_key_arn
  filename           = data.archive_file.placeholder.output_path
  source_code_hash   = data.archive_file.placeholder.output_base64sha256
  common_tags        = var.common_tags

  environment_variables = merge(local.common_env, {
    FUNCTION_PURPOSE = "artifact-processor"
  })

  additional_policy_statements = concat(
    local.base_secrets_policy,
    local.dynamodb_read_policy,
    local.dynamodb_write_policy,
    local.s3_read_policy,
    local.s3_write_policy,
    local.sfn_task_callback_policy
  )
}
