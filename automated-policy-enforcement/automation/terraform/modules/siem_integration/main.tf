#------------------------------------------------------------------------------
# Tier 2: SIEM Integration — EventBridge → Lambda → on-premises SIEM
# Forwards CRITICAL/HIGH Security Hub findings within ≤5 min delivery SLA
# Secrets Manager provides SIEM API credentials at runtime
#------------------------------------------------------------------------------

resource "aws_sqs_queue" "dlq" {
  name                              = var.dlq_name
  message_retention_seconds         = 1209600 # 14 days
  kms_master_key_id                 = var.kms_key_arn
  kms_data_key_reuse_period_seconds = 300

  tags = merge(var.common_tags, {
    Name    = var.dlq_name
    Purpose = "siem-forward-dlq"
  })
}

resource "aws_cloudwatch_log_group" "siem_lambda" {
  name              = "/aws/lambda/${var.name_prefix}-siem-forward"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-siem-forward-logs"
    Purpose = "siem-integration"
  })
}

resource "aws_iam_role" "siem_forward" {
  name        = "${var.name_prefix}-siem-forward-role"
  description = "Execution role for SIEM forwarding Lambda"

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
    Name    = "${var.name_prefix}-siem-forward-role"
    Purpose = "siem-integration"
  })
}

resource "aws_iam_role_policy" "siem_forward" {
  name = "${var.name_prefix}-siem-forward-policy"
  role = aws_iam_role.siem_forward.id

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
        Sid    = "SecretsManagerReadSiemCredentials"
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = ["arn:aws:secretsmanager:*:*:secret:${var.name_prefix}/siem/*"]
      },
      {
        Sid    = "KMSDecrypt"
        Effect = "Allow"
        Action = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = [var.kms_key_arn]
      },
      {
        Sid    = "SQSSendDLQ"
        Effect = "Allow"
        Action = ["sqs:SendMessage"]
        Resource = [aws_sqs_queue.dlq.arn]
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

resource "aws_lambda_function" "siem_forward" {
  function_name = "${var.name_prefix}-siem-forward"
  description   = "Transforms Security Hub CRITICAL/HIGH findings and delivers to on-premises SIEM API"
  role          = aws_iam_role.siem_forward.arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = var.lambda_timeout_seconds
  memory_size   = var.lambda_memory_mb

  reserved_concurrent_executions = var.reserved_concurrency

  filename         = data.archive_file.siem_forward.output_path
  source_code_hash = data.archive_file.siem_forward.output_base64sha256

  environment {
    variables = {
      LOG_LEVEL                  = var.log_level
      FINDING_SEVERITY_THRESHOLD = var.finding_severity_threshold
      SIEM_API_ENDPOINT_SECRET   = "${var.name_prefix}/siem/api-endpoint"
      SIEM_API_KEY_SECRET        = "${var.name_prefix}/siem/api-key"
      DLQ_URL                    = aws_sqs_queue.dlq.url
      DELIVERY_SLA_MINUTES       = tostring(var.delivery_sla_minutes)
    }
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }

  tracing_config {
    mode = "Active"
  }

  kms_key_arn = var.kms_key_arn

  depends_on = [aws_cloudwatch_log_group.siem_lambda]

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-siem-forward"
    Purpose = "siem-integration"
  })
}

data "archive_file" "siem_forward" {
  type        = "zip"
  output_path = "${path.module}/lambda/siem_forward.zip"
  source {
    content  = <<-PYTHON
import json, os, boto3, logging
logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "info").upper())
sm = boto3.client("secretsmanager")

def handler(event, context):
    logger.info("SIEM forwarding Lambda invoked")
    # SIEM API endpoint and key retrieved at runtime from Secrets Manager
    # Actual delivery logic implemented during Phase 2 build
    for record in event.get("Records", []):
        finding = json.loads(record.get("body", "{}"))
        logger.info("Processing finding: %s", finding.get("id", "unknown"))
    return {"statusCode": 200, "body": "processed"}
PYTHON
    filename = "index.py"
  }
}

resource "aws_cloudwatch_event_rule" "security_hub_findings" {
  name        = "${var.name_prefix}-securityhub-findings"
  description = "Capture CRITICAL and HIGH Security Hub findings for SIEM forwarding"

  event_pattern = jsonencode({
    source      = ["aws.securityhub"]
    detail-type = ["Security Hub Findings - Imported"]
    detail = {
      findings = {
        Severity = {
          Label = [var.finding_severity_threshold, "CRITICAL"]
        }
      }
    }
  })

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-securityhub-findings-rule"
    Purpose = "siem-integration"
  })
}

resource "aws_cloudwatch_event_target" "siem_lambda" {
  rule = aws_cloudwatch_event_rule.security_hub_findings.name
  arn  = aws_lambda_function.siem_forward.arn
}

resource "aws_lambda_permission" "eventbridge_siem" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.siem_forward.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.security_hub_findings.arn
}
