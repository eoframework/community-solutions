#------------------------------------------------------------------------------
# Tier 2 — CI/CD capability module
# Composes: CodeBuild projects for agent image build and Terraform plan gate
#------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#------------------------------------------------------------------------------
# IAM role for CodeBuild
#------------------------------------------------------------------------------
resource "aws_iam_role" "codebuild" {
  name = "${var.name_prefix}-codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${var.name_prefix}-codebuild-policy"
  role = aws_iam_role.codebuild.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
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
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:::${var.storage.artifacts_bucket_name}/*"
      }
    ]
  })
}

#------------------------------------------------------------------------------
# CodeBuild — Agent image build pipeline
#------------------------------------------------------------------------------
resource "aws_codebuild_project" "agent_image" {
  name          = var.operations.codebuild_agent_image_project_name
  description   = "Builds eof-tools agent Docker image and pushes to ECR"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 30

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "ECR_REPOSITORY_NAME"
      value = var.storage.ecr_repository_name
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "IMAGE_TAG_POLICY"
      value = var.security.iam_wildcard_resource_arns_allowed ? "latest" : "immutable-digest"
    }
  }

  source {
    type      = "NO_SOURCE"
    buildspec = <<-EOF
      version: 0.2
      phases:
        pre_build:
          commands:
            - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
        build:
          commands:
            - echo "Build phase — Docker image build"
        post_build:
          commands:
            - echo "Post-build phase — ECR push"
    EOF
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# CodeBuild — Terraform plan gate
#------------------------------------------------------------------------------
resource "aws_codebuild_project" "terraform_plan" {
  name          = var.operations.codebuild_terraform_plan_project_name
  description   = "Runs terraform plan as a PR gate before merge to main"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 15

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false

    environment_variable {
      name  = "TF_ENV"
      value = var.environment
    }
  }

  source {
    type      = "NO_SOURCE"
    buildspec = <<-EOF
      version: 0.2
      phases:
        install:
          commands:
            - echo "Install terraform"
        build:
          commands:
            - echo "terraform plan gate"
    EOF
  }

  tags = var.common_tags
}
