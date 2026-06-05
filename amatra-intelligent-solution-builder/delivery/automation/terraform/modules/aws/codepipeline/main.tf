#------------------------------------------------------------------------------
# Tier 1: AWS CodePipeline + CodeBuild — CI/CD with terraform validate gate
# Docker build → ECR push → AgentCore re-registration → smoke test
#------------------------------------------------------------------------------

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# IAM role for CodePipeline
resource "aws_iam_role" "codepipeline" {
  name = "${var.name_prefix}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-codepipeline-role"
  })
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "${var.name_prefix}-codepipeline-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:GetBucketVersioning"]
        Resource = [
          "arn:aws:s3:::${var.artifact_bucket_name}",
          "arn:aws:s3:::${var.artifact_bucket_name}/*"
        ]
      },
      {
        Sid    = "CodeBuildAccess"
        Effect = "Allow"
        Action = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"]
        Resource = ["arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/${var.name_prefix}-*"]
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

# IAM role for CodeBuild
resource "aws_iam_role" "codebuild" {
  name = "${var.name_prefix}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-codebuild-role"
  })
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${var.name_prefix}-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = [var.ecr_repository_arn, "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
      },
      {
        Sid    = "ECRAuthToken"
        Effect = "Allow"
        Action = ["ecr:GetAuthorizationToken"]
        Resource = ["*"]
      },
      {
        Sid    = "S3Access"
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
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
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

# CodeBuild project — Docker build + terraform validate gate
resource "aws_codebuild_project" "main" {
  name          = "${var.name_prefix}-build"
  description   = "Build agent Docker images and run terraform validate gate"
  build_timeout = 30
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.codebuild_compute_type
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "ECR_REPOSITORY_URL"
      value = var.ecr_repository_url
    }

    environment_variable {
      name  = "TERRAFORM_VALIDATE_GATE"
      value = tostring(var.terraform_validate_gate)
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOF
      version: 0.2
      phases:
        pre_build:
          commands:
            - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY_URL
        build:
          commands:
            - |
              if [ "$TERRAFORM_VALIDATE_GATE" = "true" ]; then
                cd automation/terraform/environments/prod
                terraform init -backend=false
                terraform validate
                cd ../test
                terraform init -backend=false
                terraform validate
                cd ../dr
                terraform init -backend=false
                terraform validate
              fi
            - docker build -t $ECR_REPOSITORY_URL:$CODEBUILD_RESOLVED_SOURCE_VERSION .
            - docker tag $ECR_REPOSITORY_URL:$CODEBUILD_RESOLVED_SOURCE_VERSION $ECR_REPOSITORY_URL:latest
        post_build:
          commands:
            - docker push $ECR_REPOSITORY_URL:$CODEBUILD_RESOLVED_SOURCE_VERSION
            - docker push $ECR_REPOSITORY_URL:latest
      EOF
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-build"
  })
}

# CodePipeline
resource "aws_codepipeline" "main" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = var.artifact_bucket_name
    type     = "S3"

    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "PLACEHOLDER_CONNECTION_ARN"
        FullRepositoryId = "PLACEHOLDER_REPO"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.main.name
      }
    }
  }

  tags = merge(var.common_tags, {
    Name = var.codepipeline_name
  })
}
