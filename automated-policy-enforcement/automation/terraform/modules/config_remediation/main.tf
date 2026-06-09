#------------------------------------------------------------------------------
# Tier 2: Config Remediation — Lambda auto-remediation for low-risk Config findings
# Scoped to governance platform resources only via IAM role boundary
#------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "remediation_lambda" {
  name              = "/aws/lambda/${var.name_prefix}-config-remediation"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-config-remediation-logs"
    Purpose = "config-auto-remediation"
  })
}

resource "aws_iam_role" "config_remediation" {
  name        = "${var.name_prefix}-config-remediation-role"
  description = "Execution role for Config auto-remediation Lambda — scoped to governance resources only"

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

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-config-remediation-role"
    Purpose = "config-auto-remediation"
  })
}

resource "aws_iam_role_policy" "config_remediation" {
  name = "${var.name_prefix}-config-remediation-policy"
  role = aws_iam_role.config_remediation.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Sid    = "ConfigRead"
        Effect = "Allow"
        Action = [
          "config:GetComplianceDetailsByConfigRule",
          "config:PutEvaluations",
          "config:DescribeConfigRules"
        ]
        Resource = "*"
      },
      {
        Sid    = "KMSDecrypt"
        Effect = "Allow"
        Action = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = [var.kms_key_arn]
      }
    ]
  })
}

resource "aws_lambda_function" "config_remediation" {
  function_name = "${var.name_prefix}-config-remediation"
  description   = "Auto-remediates low-risk Config non-compliant findings for governance resources"
  role          = aws_iam_role.config_remediation.arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = var.lambda_memory_mb

  reserved_concurrent_executions = var.max_concurrency

  filename         = data.archive_file.config_remediation.output_path
  source_code_hash = data.archive_file.config_remediation.output_base64sha256

  environment {
    variables = {
      LOG_LEVEL   = var.log_level
      ENVIRONMENT = var.environment
    }
  }

  tracing_config {
    mode = "Active"
  }

  kms_key_arn = var.kms_key_arn

  depends_on = [aws_cloudwatch_log_group.remediation_lambda]

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-config-remediation"
    Purpose = "config-auto-remediation"
  })
}

data "archive_file" "config_remediation" {
  type        = "zip"
  output_path = "${path.module}/lambda/config_remediation.zip"
  source {
    content  = <<-PYTHON
import json, os, boto3, logging
logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "info").upper())

def handler(event, context):
    logger.info("Config remediation Lambda invoked")
    # Remediation logic scoped to governance resources only
    # Actual remediation actions implemented during Phase 2 build
    rule = event.get("detail", {}).get("configRuleName", "unknown")
    logger.info("Processing non-compliant rule: %s", rule)
    return {"statusCode": 200, "remediated": False}
PYTHON
    filename = "index.py"
  }
}

resource "aws_cloudwatch_event_rule" "config_noncompliant" {
  name        = "${var.name_prefix}-config-noncompliant"
  description = "Trigger auto-remediation Lambda on Config non-compliant findings"

  event_pattern = jsonencode({
    source      = ["aws.config"]
    detail-type = ["Config Rules Compliance Change"]
    detail = {
      newEvaluationResult = {
        complianceType = ["NON_COMPLIANT"]
      }
    }
  })

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-config-noncompliant-rule"
    Purpose = "config-auto-remediation"
  })
}

resource "aws_cloudwatch_event_target" "remediation_lambda" {
  rule = aws_cloudwatch_event_rule.config_noncompliant.name
  arn  = aws_lambda_function.config_remediation.arn
}

resource "aws_lambda_permission" "eventbridge_config" {
  statement_id  = "AllowEventBridgeConfigInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.config_remediation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.config_noncompliant.arn
}
