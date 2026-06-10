#------------------------------------------------------------------------------
# Tier 2 — Orchestration Module
# AWS Step Functions Standard Workflow for async generation pipeline
# SOC 2 PI1 — durable state machine with retries, error handling, DLQ
#------------------------------------------------------------------------------

# IAM role for Step Functions
resource "aws_iam_role" "sfn" {
  name = "${var.name_prefix}-sfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "states.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "sfn" {
  name = "${var.name_prefix}-sfn-policy"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaInvoke"
        Effect = "Allow"
        Action = ["lambda:InvokeFunction"]
        Resource = [
          var.sonnet_invoker_arn,
          var.haiku_invoker_arn,
          var.artifact_processor_arn,
          var.prompt_assembly_arn,
          "${var.sonnet_invoker_arn}:*",
          "${var.haiku_invoker_arn}:*",
          "${var.artifact_processor_arn}:*",
          "${var.prompt_assembly_arn}:*",
        ]
      },
      {
        Sid    = "AllowDynamoDBWrite"
        Effect = "Allow"
        Action = ["dynamodb:UpdateItem", "dynamodb:PutItem"]
        Resource = "arn:aws:dynamodb:*:*:table/${var.solution_state_table_name}"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutLogEvents",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups",
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowKMSUsage"
        Effect = "Allow"
        Action = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = var.kms_key_arn
      }
    ]
  })
}

# CloudWatch Log Group for Step Functions execution logs
resource "aws_cloudwatch_log_group" "sfn" {
  name              = "/aws/states/${var.state_machine_name}"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

# Step Functions Standard Workflow State Machine
resource "aws_sfn_state_machine" "generation_workflow" {
  name     = var.state_machine_name
  role_arn = aws_iam_role.sfn.arn
  type     = "STANDARD"

  # Generation workflow: prompt-assembly → bedrock-invoke → artifact-process → complete
  definition = jsonencode({
    Comment = "Amatra ISB artifact generation pipeline — durable 30-60 min async workflow"
    StartAt = "AssemblePrompt"
    States = {
      AssemblePrompt = {
        Type     = "Task"
        Resource = var.prompt_assembly_arn
        Next     = "InvokeBedrockBranch"
        Retry = [{
          ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"]
          IntervalSeconds = var.retry_interval_seconds
          MaxAttempts     = var.retry_max_attempts
          BackoffRate     = 2
        }]
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "HandleFailure"
        }]
      }
      InvokeBedrockBranch = {
        Type = "Choice"
        Choices = [
          {
            Variable      = "$.model_tier"
            StringEquals  = "haiku"
            Next          = "InvokeBedrockHaiku"
          }
        ]
        Default = "InvokeBedrockSonnet"
      }
      InvokeBedrockSonnet = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke.waitForTaskToken"
        Parameters = {
          FunctionName = var.sonnet_invoker_arn
          "Payload.$"  = "States.JsonMerge($$, States.StringToJson(States.Format('{}', States.JsonToString($))), false)"
        }
        Next = "ProcessArtifact"
        Retry = [{
          ErrorEquals     = ["Bedrock.ThrottlingException", "Bedrock.ServiceUnavailableException", "Lambda.ServiceException"]
          IntervalSeconds = var.retry_interval_seconds
          MaxAttempts     = var.retry_max_attempts
          BackoffRate     = 2
        }]
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "HandleFailure"
        }]
        HeartbeatSeconds = 900
        TimeoutSeconds   = 950
      }
      InvokeBedrockHaiku = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke.waitForTaskToken"
        Parameters = {
          FunctionName = var.haiku_invoker_arn
          "Payload.$"  = "States.JsonMerge($$, States.StringToJson(States.Format('{}', States.JsonToString($))), false)"
        }
        Next = "ProcessArtifact"
        Retry = [{
          ErrorEquals     = ["Bedrock.ThrottlingException", "Bedrock.ServiceUnavailableException", "Lambda.ServiceException"]
          IntervalSeconds = var.retry_interval_seconds
          MaxAttempts     = var.retry_max_attempts
          BackoffRate     = 2
        }]
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "HandleFailure"
        }]
        HeartbeatSeconds = 660
        TimeoutSeconds   = 700
      }
      ProcessArtifact = {
        Type     = "Task"
        Resource = var.artifact_processor_arn
        Next     = "GenerationComplete"
        Retry = [{
          ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException"]
          IntervalSeconds = 10
          MaxAttempts     = 2
          BackoffRate     = 2
        }]
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "HandleFailure"
        }]
      }
      GenerationComplete = {
        Type = "Succeed"
      }
      HandleFailure = {
        Type     = "Task"
        Resource = var.artifact_processor_arn
        Parameters = {
          "solution_id.$" = "$.solution_id"
          status          = "FAILED"
          "error.$"       = "$.Error"
          "cause.$"       = "$.Cause"
        }
        End = true
      }
    }
  })

  logging_configuration {
    level                  = "ERROR"
    include_execution_data = false
    log_destination        = "${aws_cloudwatch_log_group.sfn.arn}:*"
  }

  tracing_configuration {
    enabled = true
  }

  tags = var.common_tags

  depends_on = [aws_iam_role_policy.sfn, aws_cloudwatch_log_group.sfn]
}
