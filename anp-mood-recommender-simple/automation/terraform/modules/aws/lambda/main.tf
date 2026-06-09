#------------------------------------------------------------------------------
# AWS Lambda Function - Tier 1 Provider Module
#------------------------------------------------------------------------------

resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "lambda_inline" {
  count  = var.inline_policy_json != "" ? 1 : 0
  name   = "${var.function_name}-policy"
  role   = aws_iam_role.lambda.id
  policy = var.inline_policy_json
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "xray" {
  count      = var.enable_xray ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda.arn
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory_mb
  timeout       = var.timeout_seconds
  architectures = ["x86_64"]

  # Use a placeholder inline zip when no deployment package is provided.
  # Replace with real artifact path (or S3 source) before deploying.
  filename         = var.deployment_package_path != "" ? var.deployment_package_path : null
  source_code_hash = var.deployment_package_path != "" ? filebase64sha256(var.deployment_package_path) : null

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  dynamic "tracing_config" {
    for_each = var.enable_xray ? [1] : []
    content {
      mode = "Active"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.basic_execution,
  ]

  tags = var.common_tags
}
