#------------------------------------------------------------------------------
# Tier 1: AWS IAM — Least-privilege execution roles for all Lambda functions
#------------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

#------------------------------------------------------------------------------
# Solution Create Lambda role
# Permissions: DynamoDB conditional quota writes, AgentCore invocation
#------------------------------------------------------------------------------
resource "aws_iam_role" "solution_create" {
  name               = "${var.name_prefix}-iam-role-solution-create"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy" "solution_create" {
  name = "${var.name_prefix}-policy-solution-create"
  role = aws_iam_role.solution_create.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.name_prefix}-lambda-solution-create:*"
      },
      {
        Sid    = "DynamoDBQuotaEnforcement"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:ConditionCheckItem"
        ]
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.users_table_name}",
          "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.global_quota_table_name}",
          "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.solutions_table_name}"
        ]
      },
      {
        Sid    = "BedrockAgentCoreInvoke"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeAgent",
          "bedrock:InvokeModel"
        ]
        Resource = [
          "arn:aws:bedrock:${var.aws_region}::foundation-model/${var.bedrock_generation_model_id}",
          "arn:aws:bedrock:${var.aws_region}::foundation-model/${var.bedrock_validation_model_id}"
        ]
      },
      {
        Sid    = "SSMParameterRead"
        Effect = "Allow"
        Action = ["ssm:GetParameter"]
        Resource = [
          "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter${var.ssm_s3_artifacts_bucket_param}",
          "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter${var.ssm_dynamodb_solutions_table_param}"
        ]
      },
      {
        Sid      = "XRayTracing"
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "solution_create_basic" {
  role       = aws_iam_role.solution_create.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#------------------------------------------------------------------------------
# Solution Status Lambda role
#------------------------------------------------------------------------------
resource "aws_iam_role" "status" {
  name               = "${var.name_prefix}-iam-role-status"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy" "status" {
  name = "${var.name_prefix}-policy-status"
  role = aws_iam_role.status.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.name_prefix}-lambda-status:*"
      },
      {
        Sid    = "DynamoDBRead"
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:Query"]
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.solutions_table_name}",
          "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.solutions_table_name}/index/*"
        ]
      },
      {
        Sid      = "XRayTracing"
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "status_basic" {
  role       = aws_iam_role.status.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#------------------------------------------------------------------------------
# Artifact Fetch Lambda role
#------------------------------------------------------------------------------
resource "aws_iam_role" "artifact_fetch" {
  name               = "${var.name_prefix}-iam-role-artifact-fetch"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy" "artifact_fetch" {
  name = "${var.name_prefix}-policy-artifact-fetch"
  role = aws_iam_role.artifact_fetch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.name_prefix}-lambda-artifact-fetch:*"
      },
      {
        Sid    = "S3PresignedUrl"
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = [
          "arn:aws:s3:::${var.artifacts_bucket_name}/${var.artifacts_prefix_raw}*",
          "arn:aws:s3:::${var.artifacts_bucket_name}/${var.artifacts_prefix_converted}*"
        ]
      },
      {
        Sid    = "DynamoDBRead"
        Effect = "Allow"
        Action = ["dynamodb:GetItem"]
        Resource = "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.solutions_table_name}"
      },
      {
        Sid      = "XRayTracing"
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "artifact_fetch_basic" {
  role       = aws_iam_role.artifact_fetch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#------------------------------------------------------------------------------
# Admin Usage Lambda role
#------------------------------------------------------------------------------
resource "aws_iam_role" "admin_usage" {
  name               = "${var.name_prefix}-iam-role-admin-usage"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy" "admin_usage" {
  name = "${var.name_prefix}-policy-admin-usage"
  role = aws_iam_role.admin_usage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.name_prefix}-lambda-admin-usage:*"
      },
      {
        Sid    = "CloudWatchMetrics"
        Effect = "Allow"
        Action = ["cloudwatch:GetMetricData", "cloudwatch:GetMetricStatistics"]
        Resource = "*"
      },
      {
        Sid    = "DynamoDBRead"
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:Scan", "dynamodb:Query"]
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.solutions_table_name}",
          "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.global_quota_table_name}",
          "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.users_table_name}"
        ]
      },
      {
        Sid      = "XRayTracing"
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin_usage_basic" {
  role       = aws_iam_role.admin_usage.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#------------------------------------------------------------------------------
# GitHub Integration Lambda role
#------------------------------------------------------------------------------
resource "aws_iam_role" "github_integration" {
  name               = "${var.name_prefix}-iam-role-github-integration"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy" "github_integration" {
  name = "${var.name_prefix}-policy-github-integration"
  role = aws_iam_role.github_integration.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.name_prefix}-lambda-github-integration:*"
      },
      {
        Sid    = "S3ArtifactRead"
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = [
          "arn:aws:s3:::${var.artifacts_bucket_name}/${var.artifacts_prefix_raw}*",
          "arn:aws:s3:::${var.artifacts_bucket_name}/${var.artifacts_prefix_converted}*",
          "arn:aws:s3:::${var.artifacts_bucket_name}/${var.terraform_prefix}*"
        ]
      },
      {
        Sid    = "SecretsManagerGitHubPAT"
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:${var.github_pat_secret_name}*"
      },
      {
        Sid    = "DynamoDBSolutionUpdate"
        Effect = "Allow"
        Action = ["dynamodb:UpdateItem", "dynamodb:GetItem"]
        Resource = "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.solutions_table_name}"
      },
      {
        Sid      = "XRayTracing"
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_integration_basic" {
  role       = aws_iam_role.github_integration.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#------------------------------------------------------------------------------
# Post-Confirmation Lambda role (Cognito trigger)
#------------------------------------------------------------------------------
resource "aws_iam_role" "post_confirmation" {
  name               = "${var.name_prefix}-iam-role-post-confirmation"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy" "post_confirmation" {
  name = "${var.name_prefix}-policy-post-confirmation"
  role = aws_iam_role.post_confirmation.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${var.name_prefix}-lambda-post-confirmation:*"
      },
      {
        Sid    = "DynamoDBUserWrite"
        Effect = "Allow"
        Action = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.users_table_name}",
          "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${var.global_quota_table_name}"
        ]
      },
      {
        Sid      = "XRayTracing"
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "post_confirmation_basic" {
  role       = aws_iam_role.post_confirmation.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
