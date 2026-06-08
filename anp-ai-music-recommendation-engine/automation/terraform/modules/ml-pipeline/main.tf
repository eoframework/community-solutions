#------------------------------------------------------------------------------
# Tier 2 — ML Pipeline: SageMaker IAM roles, Model Registry, and retraining
# schedule via EventBridge Scheduler
#------------------------------------------------------------------------------

#-- SageMaker Execution IAM Role ---------------------------------------------

resource "aws_iam_role" "sagemaker_execution" {
  name = "${var.name_prefix}-sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-sagemaker-execution-role"
  })
}

resource "aws_iam_role_policy" "sagemaker_s3_access" {
  name = "${var.name_prefix}-sagemaker-s3-policy"
  role = aws_iam_role.sagemaker_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Resource = [
          "arn:aws:s3:::${var.models_bucket_name}",
          "arn:aws:s3:::${var.models_bucket_name}/*",
          "arn:aws:s3:::${var.features_bucket_name}",
          "arn:aws:s3:::${var.features_bucket_name}/*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
        ]
        Resource = [var.model_kms_key_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_full" {
  role       = aws_iam_role.sagemaker_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

#-- SageMaker Model Registry -------------------------------------------------

resource "aws_sagemaker_model_package_group" "main" {
  model_package_group_name        = var.sagemaker_model_registry_name
  model_package_group_description = "ANP Streaming recommendation model registry - ${var.environment}"

  tags = merge(var.common_tags, {
    Name = var.sagemaker_model_registry_name
  })
}

#-- EventBridge Scheduler for weekly retraining ------------------------------

resource "aws_iam_role" "scheduler" {
  name = "${var.name_prefix}-retraining-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-retraining-scheduler-role"
  })
}

resource "aws_iam_role_policy" "scheduler_sagemaker" {
  name = "${var.name_prefix}-scheduler-sagemaker-policy"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sagemaker:StartPipelineExecution"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_scheduler_schedule" "retraining" {
  name       = "${var.name_prefix}-weekly-retraining"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.retraining_schedule_expression

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:sagemaker:startPipelineExecution"
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      PipelineName                 = "${var.name_prefix}-retraining-pipeline"
      ClientRequestToken           = "scheduled-retraining"
      PipelineExecutionDescription = "Scheduled weekly retraining"
    })
  }
}

#-- SageMaker VPC Security Group -------------------------------------------

resource "aws_security_group" "sagemaker" {
  name        = "${var.name_prefix}-sagemaker-sg"
  description = "Security group for SageMaker endpoint ENIs"
  vpc_id      = var.vpc_id

  egress {
    description = "All outbound - SageMaker needs HTTPS to AWS services"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Inference requests from Lambda application security group"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-sagemaker-sg"
  })
}
