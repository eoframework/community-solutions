terraform {
  required_version = ">= 1.8.0"

  backend "s3" {
    # Values supplied via -backend-config=backend.tfvars at `terraform init`
    # Run setup/backend/state-backend.sh prod to create the backend resources
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.project.region

  default_tags {
    tags = local.common_tags
  }
}
