#------------------------------------------------------------------------------
# Tier 2: AFT Pipeline — Account Factory for Terraform account vending
# Composes CodePipeline, CodeBuild, and Lambda primitives for ITSM-gated vending
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# IAM Role — CodePipeline execution role
#------------------------------------------------------------------------------
resource "aws_iam_role" "aft_pipeline" {
  name        = "${var.name_prefix}-aft-codepipeline-role"
  description = "Execution role for AFT account vending CodePipeline"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "codepipeline.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-aft-codepipeline-role"
    Purpose = "aft-pipeline"
  })
}

resource "aws_iam_role_policy" "aft_pipeline" {
  name = "${var.name_prefix}-aft-codepipeline-policy"
  role = aws_iam_role.aft_pipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ArtifactStore"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.tf_state_bucket_name}",
          "arn:aws:s3:::${var.tf_state_bucket_name}/*"
        ]
      },
      {
        Sid    = "KMSEncryptDecrypt"
        Effect = "Allow"
        Action = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = [var.kms_key_arn]
      },
      {
        Sid    = "CodeBuildStart"
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = "*"
      }
    ]
  })
}

#------------------------------------------------------------------------------
# IAM Role — Lambda AFT orchestration execution role
#------------------------------------------------------------------------------
resource "aws_iam_role" "aft_lambda" {
  name        = "${var.name_prefix}-aft-lambda-role"
  description = "Execution role for AFT account vending Lambda functions"

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
    Name    = "${var.name_prefix}-aft-lambda-role"
    Purpose = "aft-pipeline"
  })
}

resource "aws_iam_role_policy" "aft_lambda" {
  name = "${var.name_prefix}-aft-lambda-policy"
  role = aws_iam_role.aft_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Sid    = "DynamoDBWorkflowState"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${var.aft_workflow_table_name}"
      },
      {
        Sid    = "KMSDecrypt"
        Effect = "Allow"
        Action = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = [var.kms_key_arn]
      },
      {
        Sid    = "SecretsManagerRead"
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = ["arn:aws:secretsmanager:*:*:secret:${var.name_prefix}/itsm/*"]
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "aft_pipeline" {
  name              = "/aws/lambda/${var.name_prefix}-aft-pipeline"
  retention_in_days = 90
  kms_key_id        = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-aft-pipeline-logs"
    Purpose = "aft-pipeline"
  })
}

#------------------------------------------------------------------------------
# CodePipeline — AFT account vending pipeline with ITSM approval gate
#------------------------------------------------------------------------------
resource "aws_codepipeline" "aft" {
  name     = "${var.name_prefix}-aft-account-vending"
  role_arn = aws_iam_role.aft_pipeline.arn

  artifact_store {
    location = var.tf_state_bucket_name
    type     = "S3"

    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"
    action {
      name             = "AccountRequest"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket             = var.tf_state_bucket_name
        S3ObjectKey          = "aft/account-requests.zip"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "ITSMApproval"
    action {
      name     = "ITSMChangeApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        CustomData = "ITSM change record approval required before account vending proceeds"
      }
    }
  }

  stage {
    name = "ProvisionAccount"
    action {
      name            = "TerraformApply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = "${var.name_prefix}-aft-build"
      }
    }
  }

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-aft-account-vending"
    Purpose = "aft-pipeline"
  })
}
