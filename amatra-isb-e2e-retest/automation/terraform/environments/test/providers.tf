terraform {
  required_version = ">= 1.9.0"

  backend "s3" {
    # Populated via -backend-config=backend.tfvars at init time
    # Run setup/backend/state-backend.sh test to create backend resources
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
  region = var.networking.region

  default_tags {
    tags = {
      Solution           = "aws-agentic-presales"
      Environment        = "dev"
      Application        = "eoframework"
      ManagedBy          = "terraform"
      CostCenter         = "AMATRA-PRESALES-2026"
      DataClassification = "PREDICTif-Internal"
    }
  }
}
