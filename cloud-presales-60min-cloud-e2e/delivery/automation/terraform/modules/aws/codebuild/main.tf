#------------------------------------------------------------------------------
# Tier 1: AWS CodeBuild — Agent image pipeline and Terraform plan gate
#------------------------------------------------------------------------------

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "${var.name_prefix}-iam-role-codebuild"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${var.name_prefix}-policy-codebuild"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/codebuild/${var.name_prefix}-*:*"
      },
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
        Resource = "*"
      },
      {
        Sid    = "S3ArtifactsAccess"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:GetObjectVersion"]
        Resource = "arn:aws:s3:::${var.artifacts_bucket_name}/*"
      }
    ]
  })
}

# Agent image build project — builds eof-tools Docker image and pushes to ECR
resource "aws_codebuild_project" "agent_image" {
  name          = var.agent_image_project_name
  description   = "Build eof-tools agent container image and push to ECR"
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
      name  = "ECR_REPOSITORY_URL"
      value = var.ecr_repository_url
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
  }

  source {
    type      = "NO_SOURCE"
    buildspec = <<-EOF
      version: 0.2
      phases:
        pre_build:
          commands:
            - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY_URL
        build:
          commands:
            - echo "Build started on $(date)"
            - docker build -t $ECR_REPOSITORY_URL:$CODEBUILD_RESOLVED_SOURCE_VERSION .
        post_build:
          commands:
            - docker push $ECR_REPOSITORY_URL:$CODEBUILD_RESOLVED_SOURCE_VERSION
            - echo "Build completed on $(date)"
    EOF
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.agent_image_project_name}"
      stream_name = "build-log"
    }
  }

  tags = var.common_tags
}

# Terraform plan gate — runs terraform plan before PR merge
resource "aws_codebuild_project" "terraform_plan" {
  name          = var.terraform_plan_project_name
  description   = "Run terraform plan as a gate before pull request merge to main"
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

    environment_variable {
      name  = "TF_VERSION"
      value = "1.10.0"
    }
  }

  source {
    type      = "NO_SOURCE"
    buildspec = <<-EOF
      version: 0.2
      phases:
        install:
          commands:
            - wget -q https://releases.hashicorp.com/terraform/$TF_VERSION/terraform_$${TF_VERSION}_linux_amd64.zip
            - unzip terraform_$${TF_VERSION}_linux_amd64.zip
            - mv terraform /usr/local/bin/
        build:
          commands:
            - cd environments/prod
            - terraform init -backend=false
            - terraform validate
    EOF
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.terraform_plan_project_name}"
      stream_name = "build-log"
    }
  }

  tags = var.common_tags
}
