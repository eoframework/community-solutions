#------------------------------------------------------------------------------
# Tier 2: ITSM Integration — Lambda polling ITSM for change-approval
# Gates the AFT account vending pipeline on approved ITSM change records
# OAuth 2.0 client credentials retrieved from Secrets Manager at runtime
#------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "itsm_lambda" {
  name              = "/aws/lambda/${var.name_prefix}-itsm-integration"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-itsm-integration-logs"
    Purpose = "itsm-integration"
  })
}

resource "aws_iam_role" "itsm" {
  name        = "${var.name_prefix}-itsm-integration-role"
  description = "Execution role for ITSM change-approval polling Lambda"

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
    Name    = "${var.name_prefix}-itsm-integration-role"
    Purpose = "itsm-integration"
  })
}

resource "aws_iam_role_policy" "itsm" {
  name = "${var.name_prefix}-itsm-integration-policy"
  role = aws_iam_role.itsm.id

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
        Sid    = "SecretsManagerReadItsmCredentials"
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = ["arn:aws:secretsmanager:*:*:secret:${var.name_prefix}/itsm/*"]
      },
      {
        Sid    = "KMSDecrypt"
        Effect = "Allow"
        Action = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = [var.kms_key_arn]
      },
      {
        Sid    = "XRayTracing"
        Effect = "Allow"
        Action = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "itsm_approval" {
  function_name = "${var.name_prefix}-itsm-approval"
  description   = "Polls ITSM for change record approval before AFT pipeline execution"
  role          = aws_iam_role.itsm.arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 120
  memory_size   = var.lambda_memory_mb

  reserved_concurrent_executions = var.reserved_concurrency

  filename         = data.archive_file.itsm_approval.output_path
  source_code_hash = data.archive_file.itsm_approval.output_base64sha256

  environment {
    variables = {
      LOG_LEVEL                   = var.log_level
      ITSM_API_ENDPOINT_SECRET    = "${var.name_prefix}/itsm/api-endpoint"
      ITSM_OAUTH_CLIENT_ID_SECRET = "${var.name_prefix}/itsm/oauth-client-id"
      ITSM_OAUTH_SECRET           = "${var.name_prefix}/itsm/oauth-client-secret"
      POLL_INTERVAL_SECONDS       = tostring(var.approval_poll_interval_seconds)
      CHANGE_FREEZE_SCP_ENABLED   = tostring(var.change_freeze_scp_condition)
    }
  }

  tracing_config {
    mode = "Active"
  }

  kms_key_arn = var.kms_key_arn

  depends_on = [aws_cloudwatch_log_group.itsm_lambda]

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-itsm-approval"
    Purpose = "itsm-integration"
  })
}

data "archive_file" "itsm_approval" {
  type        = "zip"
  output_path = "${path.module}/lambda/itsm_approval.zip"
  source {
    content  = <<-PYTHON
import json, os, boto3, logging
logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "info").upper())
sm = boto3.client("secretsmanager")

def handler(event, context):
    logger.info("ITSM approval Lambda invoked")
    # ITSM API endpoint and OAuth credentials retrieved at runtime from Secrets Manager
    # Actual polling logic implemented during Phase 2 build
    change_id = event.get("change_id", "unknown")
    logger.info("Polling ITSM for change record: %s", change_id)
    return {"statusCode": 200, "approved": False, "message": "pending"}
PYTHON
    filename = "index.py"
  }
}
