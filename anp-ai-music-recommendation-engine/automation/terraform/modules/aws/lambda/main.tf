#------------------------------------------------------------------------------
# Tier 1 — AWS Lambda: Function with VPC attachment, X-Ray, and CloudWatch
# Provides a placeholder zip for `terraform validate` — real code deployed via CI/CD
#------------------------------------------------------------------------------

data "archive_file" "placeholder" {
  type        = "zip"
  output_path = "${path.module}/placeholder_${var.function_name}.zip"

  source {
    content  = "def handler(event, context): return {'statusCode': 200}"
    filename = "handler.py"
  }
}

resource "aws_lambda_function" "main" {
  function_name = var.function_name
  role          = var.execution_role_arn
  handler       = var.handler
  runtime       = var.runtime
  architectures = [var.architecture]
  memory_size   = var.memory_size
  timeout       = var.timeout

  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  reserved_concurrent_executions = var.reserved_concurrent_executions

  dynamic "vpc_config" {
    for_each = length(var.vpc_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  tracing_config {
    mode = var.xray_tracing ? "Active" : "PassThrough"
  }

  environment {
    variables = var.environment_variables
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
  ]

  tags = merge(var.common_tags, {
    Name = var.function_name
  })

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "/aws/lambda/${var.function_name}"
  })
}
