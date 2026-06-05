#------------------------------------------------------------------------------
# Tier 1: AWS Step Functions — Solution generation orchestration state machine
# Standard Workflow for durable state management and full execution history
#------------------------------------------------------------------------------

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# IAM execution role for Step Functions
resource "aws_iam_role" "sfn_exec" {
  name = "${var.name_prefix}-sfn-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-sfn-exec-role"
  })
}

resource "aws_iam_role_policy" "sfn_platform" {
  name = "${var.name_prefix}-sfn-platform-policy"
  role = aws_iam_role.sfn_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LambdaInvoke"
        Effect = "Allow"
        Action = ["lambda:InvokeFunction"]
        Resource = values(var.lambda_function_arns)
      },
      {
        Sid    = "DynamoDBStateUpdates"
        Effect = "Allow"
        Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"]
        Resource = ["arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.table_solution_state_name}"]
      },
      {
        Sid    = "S3ArtifactAccess"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject"]
        Resource = [
          "arn:aws:s3:::${var.artifact_bucket_name}",
          "arn:aws:s3:::${var.artifact_bucket_name}/*"
        ]
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = ["*"]
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = [var.kms_key_arn]
      }
    ]
  })
}

# CloudWatch Log Group for Step Functions executions
resource "aws_cloudwatch_log_group" "sfn" {
  name              = "/amatra/${var.name_prefix}/stepfunctions"
  retention_in_days = 90
  kms_key_id        = var.kms_key_arn

  tags = var.common_tags
}

# SQS Dead Letter Queue for unresolvable failures
resource "aws_sqs_queue" "dlq" {
  name                       = "${var.name_prefix}-sfn-dlq"
  message_retention_seconds  = 1209600 # 14 days
  kms_master_key_id          = "alias/aws/sqs"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-sfn-dlq"
  })
}

# Step Functions Standard Workflow state machine
resource "aws_sfn_state_machine" "solution_generation" {
  name     = "${var.name_prefix}-solution-generation"
  role_arn = aws_iam_role.sfn_exec.arn

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sfn.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }

  # State machine definition: 5-agent pipeline with retry and DLQ escalation
  definition = jsonencode({
    Comment = "Amatra 5-agent solution generation pipeline — Input Validator → Pre-Sales Gen → Delivery Gen → Code Gen → EO Validator"
    StartAt = "InputValidation"
    TimeoutSeconds = var.execution_timeout_seconds

    States = {
      InputValidation = {
        Type     = "Task"
        Resource = try(var.lambda_function_arns["api_handler"], "arn:aws:lambda:us-west-2:000000000000:function:placeholder")
        Parameters = {
          "phase": "input_validation"
          "solution_id.$": "$.solution_id"
          "brief_s3_key.$": "$.brief_s3_key"
        }
        Retry = [
          {
            ErrorEquals     = ["States.TaskFailed"]
            IntervalSeconds = 5
            MaxAttempts     = 2
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "HandleFailure"
          }
        ]
        Next = "GenerationPhase"
      }

      GenerationPhase = {
        Type = "Parallel"
        Branches = [
          {
            StartAt = "PreSalesGeneration"
            States = {
              PreSalesGeneration = {
                Type     = "Task"
                Resource = try(var.lambda_function_arns["api_handler"], "arn:aws:lambda:us-west-2:000000000000:function:placeholder")
                Parameters = {
                  "phase": "presales_generation"
                  "solution_id.$": "$.solution_id"
                }
                Retry = [
                  {
                    ErrorEquals     = ["States.TaskFailed"]
                    IntervalSeconds = 10
                    MaxAttempts     = 3
                    BackoffRate     = 2
                  }
                ]
                End = true
              }
            }
          },
          {
            StartAt = "DeliveryGeneration"
            States = {
              DeliveryGeneration = {
                Type     = "Task"
                Resource = try(var.lambda_function_arns["api_handler"], "arn:aws:lambda:us-west-2:000000000000:function:placeholder")
                Parameters = {
                  "phase": "delivery_generation"
                  "solution_id.$": "$.solution_id"
                }
                Retry = [
                  {
                    ErrorEquals     = ["States.TaskFailed"]
                    IntervalSeconds = 10
                    MaxAttempts     = 3
                    BackoffRate     = 2
                  }
                ]
                End = true
              }
            }
          },
          {
            StartAt = "CodeGeneration"
            States = {
              CodeGeneration = {
                Type     = "Task"
                Resource = try(var.lambda_function_arns["api_handler"], "arn:aws:lambda:us-west-2:000000000000:function:placeholder")
                Parameters = {
                  "phase": "code_generation"
                  "solution_id.$": "$.solution_id"
                }
                Retry = [
                  {
                    ErrorEquals     = ["States.TaskFailed"]
                    IntervalSeconds = 10
                    MaxAttempts     = 3
                    BackoffRate     = 2
                  }
                ]
                End = true
              }
            }
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "HandleFailure"
          }
        ]
        Next = "EOValidation"
      }

      EOValidation = {
        Type     = "Task"
        Resource = try(var.lambda_function_arns["api_handler"], "arn:aws:lambda:us-west-2:000000000000:function:placeholder")
        Parameters = {
          "phase": "eo_validation"
          "solution_id.$": "$.solution_id"
        }
        Retry = [
          {
            ErrorEquals     = ["States.TaskFailed"]
            IntervalSeconds = 5
            MaxAttempts     = 3
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "HandleFailure"
          }
        ]
        Next = "Complete"
      }

      Complete = {
        Type = "Succeed"
      }

      HandleFailure = {
        Type = "Task"
        Resource = "arn:aws:states:::sqs:sendMessage"
        Parameters = {
          QueueUrl      = aws_sqs_queue.dlq.url
          "MessageBody.$" = "$"
        }
        Next = "ExecutionFailed"
      }

      ExecutionFailed = {
        Type  = "Fail"
        Error = "SolutionGenerationFailed"
        Cause = "Agent pipeline failed — see DLQ for details"
      }
    }
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-solution-generation"
  })

  depends_on = [aws_iam_role_policy.sfn_platform]
}
