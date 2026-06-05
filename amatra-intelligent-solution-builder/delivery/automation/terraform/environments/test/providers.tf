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
  region = var.project.region

  default_tags {
    tags = {
      Solution           = var.project.solution_name
      Environment        = "test"
      ManagedBy          = "terraform"
      CostCenter         = var.project.opportunity_id
      Owner              = "amatra-engineering"
      DataClassification = "PREDICTif-Confidential"
      Project            = var.project.solution_name
    }
  }
}
