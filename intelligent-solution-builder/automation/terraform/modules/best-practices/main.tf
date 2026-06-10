#------------------------------------------------------------------------------
# Tier 2 — Best Practices Module
# CloudTrail, AWS Config rules, Cognito backup, and compliance controls
# SOC 2 CC7 / OE — audit logging, change management, and compliance monitoring
#------------------------------------------------------------------------------

# CloudTrail for all management events and S3 data events
resource "aws_cloudtrail" "this" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = "${var.name_prefix}-trail"
  s3_bucket_name                = var.cloudtrail_bucket_name
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true
  kms_key_id                    = var.cloudtrail_kms_key_arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    # S3 data events for artifact bucket
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::${var.artifacts_bucket_name}/"]
    }
  }

  tags = var.common_tags
}

# AWS Config recorder (tracks resource configuration changes)
resource "aws_config_configuration_recorder" "this" {
  count    = var.enable_config_rules ? 1 : 0
  name     = "${var.name_prefix}-config-recorder"

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  role_arn = aws_iam_role.config[0].arn
}

resource "aws_iam_role" "config" {
  count = var.enable_config_rules ? 1 : 0
  name  = "${var.name_prefix}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "config" {
  count      = var.enable_config_rules ? 1 : 0
  role       = aws_iam_role.config[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# Cognito user pool nightly export Lambda — backs up user records to S3
resource "aws_cloudwatch_event_rule" "cognito_export" {
  name                = "${var.name_prefix}-cognito-export"
  description         = "Nightly Cognito user pool export to S3 for RTO ≤30 min restore"
  schedule_expression = var.cognito_export_schedule
  tags                = var.common_tags
}

resource "aws_iam_role" "cognito_export" {
  name = "${var.name_prefix}-cognito-export-role"

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

resource "aws_iam_role_policy" "cognito_export" {
  name = "${var.name_prefix}-cognito-export-policy"
  role = aws_iam_role.cognito_export.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["cognito-idp:ListUsers", "cognito-idp:ListGroups", "cognito-idp:ListUsersInGroup"]
        Resource = "arn:aws:cognito-idp:*:*:userpool/${var.cognito_user_pool_id}"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "arn:aws:s3:::${var.artifacts_bucket_name}/backups/cognito/*"
      },
      {
        Effect   = "Allow"
        Action   = ["kms:GenerateDataKey", "kms:Decrypt"]
        Resource = var.kms_key_arn
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Placeholder Lambda for Cognito export
data "archive_file" "cognito_export_placeholder" {
  type        = "zip"
  output_path = "${path.module}/cognito_export_placeholder.zip"

  source {
    content  = "# Cognito export Lambda — replaced by CI/CD\ndef lambda_handler(event, context): return {'statusCode': 200}"
    filename = "handler.py"
  }
}

resource "aws_lambda_function" "cognito_export" {
  function_name    = "isb-cognito-export-${var.environment}"
  role             = aws_iam_role.cognito_export.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 300
  memory_size      = 256
  filename         = data.archive_file.cognito_export_placeholder.output_path
  source_code_hash = data.archive_file.cognito_export_placeholder.output_base64sha256

  environment {
    variables = {
      COGNITO_USER_POOL_ID = var.cognito_user_pool_id
      EXPORT_BUCKET        = var.artifacts_bucket_name
      EXPORT_PREFIX        = "backups/cognito"
    }
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "cognito_export" {
  rule      = aws_cloudwatch_event_rule.cognito_export.name
  target_id = "CognitoExportLambda"
  arn       = aws_lambda_function.cognito_export.arn
}

resource "aws_lambda_permission" "cognito_export" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cognito_export.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cognito_export.arn
}
