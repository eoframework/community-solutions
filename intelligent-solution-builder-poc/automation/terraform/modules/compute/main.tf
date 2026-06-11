###############################################################################
# Tier 2 Solution Module — Compute
# Composes ECR repositories, SQS queues, Step Functions workflow,
# and all Lambda functions for the ISB generation pipeline.
###############################################################################

locals {
  # Lambda functions and their configurations
  lambda_functions = {
    brief-submission = {
      memory_size          = var.compute.brief_submission_memory_mb
      timeout_seconds      = var.compute.brief_submission_timeout_seconds
      reserved_concurrency = var.compute.brief_submission_reserved_concurrency
      provisioned          = var.compute.brief_submission_provisioned_concurrency
    }
    job-status = {
      memory_size          = var.compute.job_status_memory_mb
      timeout_seconds      = var.compute.job_status_timeout_seconds
      reserved_concurrency = var.compute.job_status_reserved_concurrency
      provisioned          = var.compute.job_status_provisioned_concurrency
    }
    artifact-retrieval = {
      memory_size          = var.compute.artifact_retrieval_memory_mb
      timeout_seconds      = var.compute.artifact_retrieval_timeout_seconds
      reserved_concurrency = var.compute.artifact_retrieval_reserved_concurrency
      provisioned          = 0
    }
    admin-governance = {
      memory_size          = var.compute.admin_governance_memory_mb
      timeout_seconds      = var.compute.admin_governance_timeout_seconds
      reserved_concurrency = var.compute.admin_governance_reserved_concurrency
      provisioned          = 0
    }
    bedrock-orchestration = {
      memory_size          = var.compute.bedrock_orchestration_memory_mb
      timeout_seconds      = var.compute.bedrock_orchestration_timeout_seconds
      reserved_concurrency = var.compute.bedrock_orchestration_reserved_concurrency
      provisioned          = 0
    }
    output-validation = {
      memory_size          = var.compute.output_validation_memory_mb
      timeout_seconds      = var.compute.output_validation_timeout_seconds
      reserved_concurrency = var.compute.output_validation_reserved_concurrency
      provisioned          = 0
    }
    artifact-template = {
      memory_size          = var.compute.artifact_template_memory_mb
      timeout_seconds      = var.compute.artifact_template_timeout_seconds
      reserved_concurrency = var.compute.artifact_template_reserved_concurrency
      provisioned          = 0
    }
    ses-notification = {
      memory_size          = var.compute.ses_notification_memory_mb
      timeout_seconds      = var.compute.ses_notification_timeout_seconds
      reserved_concurrency = 10
      provisioned          = 0
    }
    health-check = {
      memory_size          = var.compute.health_check_memory_mb
      timeout_seconds      = 5
      reserved_concurrency = 5
      provisioned          = 0
    }
  }
}

#--------------------------------------
# ECR Repositories (one per Lambda)
#--------------------------------------
module "ecr" {
  for_each = local.lambda_functions
  source   = "../aws/ecr"

  repository_name      = "${var.ecr_repository_prefix}/${each.key}"
  image_tag_mutability = var.ecr_image_tag_mutability
  kms_key_arn          = var.kms_artifacts_key_arn
  force_delete         = var.force_destroy
  common_tags          = var.common_tags
}

#--------------------------------------
# SQS Dead-Letter Queue
#--------------------------------------
module "sqs_dlq" {
  source = "../aws/sqs"

  queue_name                = var.dlq_name
  fifo_queue                = false
  message_retention_seconds = var.sqs_message_retention_seconds
  kms_key_id                = var.kms_artifacts_key_arn
  common_tags               = var.common_tags
}

#--------------------------------------
# SQS FIFO Generation Queue
#--------------------------------------
module "sqs_generation" {
  source = "../aws/sqs"

  queue_name                  = var.generation_queue_name
  fifo_queue                  = true
  content_based_deduplication = true
  message_retention_seconds   = var.sqs_message_retention_seconds
  visibility_timeout_seconds  = 960
  kms_key_id                  = var.kms_artifacts_key_arn
  dlq_arn                     = module.sqs_dlq.queue_arn
  max_receive_count           = var.sqs_max_receive_count
  common_tags                 = var.common_tags
}

#--------------------------------------
# Step Functions Workflow
#--------------------------------------
module "step_functions" {
  source = "../aws/step-functions"

  state_machine_name  = var.workflow_name
  enable_xray_tracing = true
  kms_key_arn         = var.kms_audit_key_arn
  log_retention_days  = var.log_retention_days

  definition = jsonencode({
    Comment = "Amatra ISB Artifact Generation Workflow"
    StartAt = "ProcessArtifacts"
    States = {
      ProcessArtifacts = {
        Type    = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = "${var.name_prefix}-bedrock-orchestration"
          "Payload.$"  = "$"
        }
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException", "ThrottlingException"]
            IntervalSeconds = var.sfn_retry_interval_seconds
            MaxAttempts     = var.sfn_max_retry_attempts
            BackoffRate     = var.sfn_retry_backoff_rate
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "HandleFailure"
          }
        ]
        Next = "ValidateOutput"
      }
      ValidateOutput = {
        Type    = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = "${var.name_prefix}-output-validation"
          "Payload.$"  = "$"
        }
        Next = "PopulateTemplate"
      }
      PopulateTemplate = {
        Type    = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = "${var.name_prefix}-artifact-template"
          "Payload.$"  = "$"
        }
        Next = "NotifySuccess"
      }
      NotifySuccess = {
        Type    = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = "${var.name_prefix}-ses-notification"
          "Payload.$"  = "$"
        }
        End = true
      }
      HandleFailure = {
        Type    = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = "${var.name_prefix}-ses-notification"
          Payload = {
            status = "FAILED"
            "context.$" = "$"
          }
        }
        End = true
      }
    }
  })

  iam_policy_statements = [
    {
      Effect   = "Allow"
      Action   = ["lambda:InvokeFunction"]
      Resource = ["arn:aws:lambda:*:*:function:${var.name_prefix}-*"]
    },
    {
      Effect   = "Allow"
      Action   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      Resource = [module.sqs_generation.queue_arn]
    }
  ]

  common_tags = var.common_tags
}

#--------------------------------------
# Lambda Functions
#--------------------------------------
module "lambda" {
  for_each = local.lambda_functions
  source   = "../aws/lambda"

  function_name        = "${var.name_prefix}-${each.key}"
  image_uri            = "${module.ecr[each.key].repository_url}:latest"
  architecture         = var.compute.architecture
  memory_size          = each.value.memory_size
  timeout_seconds      = each.value.timeout_seconds
  reserved_concurrency = each.value.reserved_concurrency
  provisioned_concurrency = each.value.provisioned

  environment      = var.environment
  log_level        = var.log_level
  app_version      = var.app_version
  log_retention_days = var.log_retention_days
  kms_key_arn      = var.kms_audit_key_arn

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.lambda_security_group_id]
  enable_xray_tracing = true

  environment_variables = {
    SOLUTION_STATE_TABLE    = var.solution_state_table_name
    USAGE_TRACKING_TABLE    = var.usage_tracking_table_name
    AUDIT_TABLE             = var.audit_table_name
    ARTIFACTS_BUCKET        = var.artifacts_bucket_name
    GENERATION_QUEUE_URL    = module.sqs_generation.queue_url
    STEP_FUNCTIONS_ARN      = module.step_functions.state_machine_arn
    BEDROCK_MODEL_ID        = var.bedrock_model_id
    BEDROCK_REGION          = var.bedrock_region
    BEDROCK_MAX_TOKENS      = tostring(var.bedrock_max_tokens_per_artifact)
    PRESIGNED_URL_EXPIRY    = tostring(var.presigned_url_expiry_seconds)
  }

  iam_policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem",
        "dynamodb:DeleteItem", "dynamodb:Query", "dynamodb:Scan"
      ]
      Resource = [
        var.solution_state_table_arn,
        "${var.solution_state_table_arn}/index/*",
        var.usage_tracking_table_arn,
        var.audit_table_arn
      ]
    },
    {
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
      Resource = [
        var.artifacts_bucket_arn,
        "${var.artifacts_bucket_arn}/*"
      ]
    },
    {
      Effect   = "Allow"
      Action   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      Resource = [module.sqs_generation.queue_arn, module.sqs_dlq.queue_arn]
    },
    {
      Effect   = "Allow"
      Action   = ["states:StartExecution", "states:DescribeExecution"]
      Resource = [module.step_functions.state_machine_arn]
    },
    {
      Effect   = "Allow"
      Action   = ["bedrock:InvokeModel"]
      Resource = ["arn:aws:bedrock:${var.bedrock_region}::foundation-model/${var.bedrock_model_id}"]
    },
    {
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = ["arn:aws:secretsmanager:*:*:secret:/amatra/${var.environment}/*"]
    },
    {
      Effect   = "Allow"
      Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
      Resource = [var.kms_artifacts_key_arn, var.kms_database_key_arn]
    },
    {
      Effect   = "Allow"
      Action   = ["ses:SendEmail", "ses:SendRawEmail"]
      Resource = ["*"]
    }
  ]

  common_tags = var.common_tags
  depends_on  = [module.ecr, module.sqs_generation, module.step_functions]
}
