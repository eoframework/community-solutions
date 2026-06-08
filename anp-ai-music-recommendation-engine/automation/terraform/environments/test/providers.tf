terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    # Values loaded from backend.tfvars via -backend-config flag
    # Run setup/backend/state-backend.sh to create backend resources
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region  = var.project.region
  profile = try(var.project.aws_profile, "") != "" ? var.project.aws_profile : null

  default_tags {
    tags = {
      Solution    = var.project.solution_name
      Environment = "test"
      Application = var.project.application_name
      CostCenter  = var.project.cost_center
      ManagedBy   = "terraform"
      Owner       = "cloud-coe"
    }
  }
}
