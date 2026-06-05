#------------------------------------------------------------------------------
# Tier 1: AWS Lambda — 11 API routes + post-confirmation + quota-reset triggers
# IAM execution roles per function; VPC-attached; ARM64/Graviton2 runtime
#------------------------------------------------------------------------------

data "aws_region" "current" {}

# IAM execution role — shared base for all Lambda functions (scoped per function via inline policies)
resource "aws_iam_role" "lambda_exec" {
  name = "${var.name_prefix}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-lambda-exec-role"
  })
}

# VPC execution policy
resource "aws_iam_role_policy_attachment" "vpc_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Inline policy — scoped access to DynamoDB tables, S3, Secrets Manager, Step Functions
resource "aws_iam_role_policy" "lambda_platform" {
  name = "${var.name_prefix}-lambda-platform-policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:ConditionCheck"
        ]
        Resource = [
          "arn:aws:dynamodb:${data.aws_region.current.name}:*:table/${var.table_user_profiles_name}",
          "arn:aws:dynamodb:${data.aws_region.current.name}:*:table/${var.table_solution_state_name}",
          "arn:aws:dynamodb:${data.aws_region.current.name}:*:table/${var.table_quota_global_name}"
        ]
      },
      {
        Sid    = "S3ArtifactAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.artifact_bucket_name}",
          "arn:aws:s3:::${var.artifact_bucket_name}/*"
        ]
      },
      {
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = [var.github_pat_secret_arn]
      },
      {
        Sid    = "StepFunctionsStart"
        Effect = "Allow"
        Action = ["states:StartExecution", "states:DescribeExecution", "states:StopExecution"]
        Resource = ["arn:aws:states:${data.aws_region.current.name}:*:stateMachine:${var.name_prefix}-*"]
      },
      {
        Sid    = "KMSDecrypt"
        Effect = "Allow"
        Action = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = [var.kms_key_arn]
      },
      {
        Sid    = "CloudWatchMetrics"
        Effect = "Allow"
        Action = ["cloudwatch:PutMetricData"]
        Resource = ["*"]
      },
      {
        Sid    = "SSMParameterRead"
        Effect = "Allow"
        Action = ["ssm:GetParameter", "ssm:GetParameters"]
        Resource = ["arn:aws:ssm:${data.aws_region.current.name}:*:parameter/*"]
      },
      {
        Sid    = "CognitoRead"
        Effect = "Allow"
        Action = ["cognito-idp:AdminGetUser", "cognito-idp:ListUsers"]
        Resource = ["arn:aws:cognito-idp:${data.aws_region.current.name}:*:userpool/${var.cognito_user_pool_id}"]
      }
    ]
  })
}

# Security group for Lambda in VPC
resource "aws_security_group" "lambda" {
  name        = "${var.name_prefix}-lambda-sg"
  description = "Security group for Lambda functions — egress to VPC endpoints and NAT"
  vpc_id      = var.vpc_id

  egress {
    description = "HTTPS to AWS services via VPC endpoints and NAT"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-lambda-sg"
  })
}

# CloudWatch Log Group for Lambda functions
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/amatra/${var.name_prefix}/lambda"
  retention_in_days = 90
  kms_key_id        = var.kms_key_arn

  tags = var.common_tags
}

# Placeholder Lambda function for API routes (container image populated post ECR push)
resource "aws_lambda_function" "api_handler" {
  function_name = "${var.name_prefix}-api-handler"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"
  image_uri     = "${var.ecr_repository_url}:latest"
  architectures = ["arm64"]
  memory_size   = var.memory_mb
  timeout       = var.timeout_seconds

  reserved_concurrent_executions = var.reserved_concurrency

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      LOG_LEVEL                    = var.log_level
      METRICS_NAMESPACE            = var.metrics_namespace
      TABLE_USER_PROFILES          = var.table_user_profiles_name
      TABLE_SOLUTION_STATE         = var.table_solution_state_name
      TABLE_QUOTA_GLOBAL           = var.table_quota_global_name
      ARTIFACT_BUCKET              = var.artifact_bucket_name
      COGNITO_USER_POOL_ID         = var.cognito_user_pool_id
      GENERATION_TIMEOUT_MINUTES   = tostring(var.generation_timeout_minutes)
      VALIDATION_RETRY_LIMIT       = tostring(var.validation_retry_limit)
      GITHUB_PAT_SECRET_ARN        = var.github_pat_secret_arn
    }
  }

  logging_config {
    log_format = "JSON"
    log_group  = aws_cloudwatch_log_group.lambda.name
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-api-handler"
  })

  depends_on = [aws_iam_role_policy_attachment.vpc_exec, aws_iam_role_policy.lambda_platform]
}

# Quota reset Lambda — EventBridge cron trigger for monthly quota counter reset
resource "aws_lambda_function" "quota_reset" {
  function_name = "${var.name_prefix}-quota-reset"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"
  image_uri     = "${var.ecr_repository_url}:latest"
  architectures = ["arm64"]
  memory_size   = 256
  timeout       = 60

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      TABLE_USER_PROFILES = var.table_user_profiles_name
      TABLE_QUOTA_GLOBAL  = var.table_quota_global_name
      LOG_LEVEL           = var.log_level
    }
  }

  logging_config {
    log_format = "JSON"
    log_group  = aws_cloudwatch_log_group.lambda.name
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-quota-reset"
  })

  depends_on = [aws_iam_role_policy_attachment.vpc_exec, aws_iam_role_policy.lambda_platform]
}

# EventBridge rule — monthly quota reset on the 1st of each month
resource "aws_cloudwatch_event_rule" "quota_reset" {
  name                = "${var.name_prefix}-quota-reset-schedule"
  description         = "Monthly quota counter reset — runs at 00:00 UTC on the 1st of each month"
  schedule_expression = var.quota_reset_schedule

  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "quota_reset" {
  rule      = aws_cloudwatch_event_rule.quota_reset.name
  target_id = "QuotaResetLambda"
  arn       = aws_lambda_function.quota_reset.arn
}

resource "aws_lambda_permission" "quota_reset_eventbridge" {
  statement_id  = "AllowEventBridgeQuotaReset"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.quota_reset.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.quota_reset.arn
}
