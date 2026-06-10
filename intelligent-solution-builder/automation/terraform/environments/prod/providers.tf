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
  }
}

provider "aws" {
  region = var.aws.region

  default_tags {
    tags = local.common_tags
  }
}
