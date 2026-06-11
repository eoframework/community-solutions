###############################################################################
# Tier 1 Provider Module — AWS Lambda
# Creates a Lambda function (container image via ECR), IAM execution role,
# CloudWatch Log Group, reserved concurrency, and optional provisioned
# concurrency.
###############################################################################

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

#--------------------------------------
# CloudWatch Log Group (pre-created for retention control)
#--------------------------------------
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = var.common_tags
}

#--------------------------------------
# IAM Execution Role
#--------------------------------------
resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "vpc_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "xray" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy" "custom" {
  count  = length(var.iam_policy_statements) > 0 ? 1 : 0
  name   = "${var.function_name}-policy"
  role   = aws_iam_role.lambda.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.iam_policy_statements
  })
}

#--------------------------------------
# Lambda Function
#--------------------------------------
resource "aws_lambda_function" "main" {
  function_name = var.function_name
  role          = aws_iam_role.lambda.arn
  package_type  = "Image"
  image_uri     = var.image_uri
  architectures = [var.architecture]
  memory_size   = var.memory_size
  timeout       = var.timeout_seconds

  reserved_concurrent_executions = var.reserved_concurrency

  environment {
    variables = merge(
      {
        ENVIRONMENT      = var.environment
        LOG_LEVEL        = var.log_level
        APP_VERSION      = var.app_version
        POWERTOOLS_SERVICE_NAME = var.function_name
      },
      var.environment_variables
    )
  }

  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  tracing_config {
    mode = var.enable_xray_tracing ? "Active" : "PassThrough"
  }

  tags = merge(var.common_tags, {
    Name = var.function_name
  })

  depends_on = [
    aws_cloudwatch_log_group.main,
    aws_iam_role_policy_attachment.vpc_execution
  ]
}

#--------------------------------------
# Lambda Alias (blue/green support)
#--------------------------------------
resource "aws_lambda_alias" "live" {
  name             = "live"
  function_name    = aws_lambda_function.main.function_name
  function_version = "$LATEST"
}

#--------------------------------------
# Provisioned Concurrency
#--------------------------------------
resource "aws_lambda_provisioned_concurrency_config" "main" {
  count                             = var.provisioned_concurrency > 0 ? 1 : 0
  function_name                     = aws_lambda_function.main.function_name
  qualifier                         = aws_lambda_alias.live.name
  provisioned_concurrent_executions = var.provisioned_concurrency
}
