#------------------------------------------------------------------------------
# AWS Lambda Module - Tier 1 Provider Primitive
# Creates Lambda function with IAM role, log group, and security group
# Note: Zip functions reference a placeholder archive created by archive_file data source.
#       The lifecycle ignore_changes block ensures Terraform does not overwrite
#       code deployed by the CI/CD pipeline.
#------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

#------------------------------------------------------------------------------
# Inline placeholder archive (CI/CD pipeline replaces actual function code)
#------------------------------------------------------------------------------
data "archive_file" "placeholder" {
  count       = var.package_type == "Zip" ? 1 : 0
  type        = "zip"
  output_path = "${path.module}/placeholder_${var.function_name_suffix}.zip"

  source {
    content  = "# Placeholder — replaced by CI/CD pipeline\ndef lambda_handler(event, context): return {'statusCode': 200}"
    filename = "handler.py"
  }
}

#------------------------------------------------------------------------------
# CloudWatch Log Group
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "main" {
  name              = "/eofw/${var.environment}/lambda/${var.function_name_suffix}"
  retention_in_days = var.log_retention_days

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# IAM Role for Lambda
#------------------------------------------------------------------------------
resource "aws_iam_role" "main" {
  name = "${var.name_prefix}-role-fn-${var.function_name_suffix}"

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

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Base Lambda Execution Policy (VPC + CloudWatch Logs)
#------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "vpc_execution" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

#------------------------------------------------------------------------------
# Custom IAM Policy for the Lambda function
#------------------------------------------------------------------------------
resource "aws_iam_role_policy" "custom" {
  count  = var.policy_json != "" ? 1 : 0
  name   = "${var.name_prefix}-policy-fn-${var.function_name_suffix}"
  role   = aws_iam_role.main.id
  policy = var.policy_json
}

#------------------------------------------------------------------------------
# Security Group for Lambda in VPC
#------------------------------------------------------------------------------
resource "aws_security_group" "lambda" {
  name        = "${var.name_prefix}-sg-fn-${var.function_name_suffix}"
  description = "Security group for Lambda function ${var.function_name_suffix}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound for AWS SDK calls"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-sg-fn-${var.function_name_suffix}"
  })
}

#------------------------------------------------------------------------------
# Lambda Function (Zip package type)
#------------------------------------------------------------------------------
resource "aws_lambda_function" "zip" {
  count = var.package_type == "Zip" ? 1 : 0

  function_name    = "${var.name_prefix}-fn-${var.function_name_suffix}"
  description      = var.description
  role             = aws_iam_role.main.arn
  runtime          = var.runtime
  handler          = var.handler
  package_type     = "Zip"
  memory_size      = var.memory_mb
  timeout          = var.timeout_seconds
  architectures    = [var.architecture]
  filename         = data.archive_file.placeholder[0].output_path
  source_code_hash = data.archive_file.placeholder[0].output_base64sha256

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  tracing_config {
    mode = var.xray_tracing_mode
  }

  depends_on = [
    aws_iam_role_policy_attachment.vpc_execution,
    aws_cloudwatch_log_group.main
  ]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-fn-${var.function_name_suffix}"
  })

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

#------------------------------------------------------------------------------
# Lambda Function (Container Image package type)
#------------------------------------------------------------------------------
resource "aws_lambda_function" "image" {
  count = var.package_type == "Image" ? 1 : 0

  function_name = "${var.name_prefix}-fn-${var.function_name_suffix}"
  description   = var.description
  role          = aws_iam_role.main.arn
  package_type  = "Image"
  image_uri     = var.image_uri
  memory_size   = var.memory_mb
  timeout       = var.timeout_seconds
  architectures = [var.architecture]

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  tracing_config {
    mode = var.xray_tracing_mode
  }

  depends_on = [
    aws_iam_role_policy_attachment.vpc_execution,
    aws_cloudwatch_log_group.main
  ]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-fn-${var.function_name_suffix}"
  })

  lifecycle {
    ignore_changes = [image_uri]
  }
}
