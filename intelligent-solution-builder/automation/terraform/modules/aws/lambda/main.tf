#------------------------------------------------------------------------------
# Tier 1 — AWS Lambda Function primitive
# Single-purpose reusable Lambda function with IAM role and CloudWatch log group
#------------------------------------------------------------------------------

resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "custom" {
  count  = length(var.additional_policy_statements) > 0 ? 1 : 0
  name   = "${var.function_name}-policy"
  role   = aws_iam_role.lambda.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.additional_policy_statements
  })
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = var.common_tags
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda.arn
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout

  # Placeholder package — replaced by CI/CD deployment
  filename         = var.filename
  source_code_hash = var.source_code_hash

  reserved_concurrent_executions = var.reserved_concurrency

  environment {
    variables = var.environment_variables
  }

  dynamic "tracing_config" {
    for_each = var.enable_xray ? [1] : []
    content {
      mode = "Active"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.basic_execution,
    aws_cloudwatch_log_group.lambda,
  ]

  tags = var.common_tags
}

resource "aws_lambda_alias" "this" {
  name             = var.alias_name
  description      = "Deployment alias for ${var.function_name}"
  function_name    = aws_lambda_function.this.function_name
  function_version = "$LATEST"
}

resource "aws_lambda_provisioned_concurrency_config" "this" {
  count = var.provisioned_concurrency > 0 ? 1 : 0

  function_name                     = aws_lambda_function.this.function_name
  qualifier                         = aws_lambda_alias.this.name
  provisioned_concurrent_executions = var.provisioned_concurrency
}
