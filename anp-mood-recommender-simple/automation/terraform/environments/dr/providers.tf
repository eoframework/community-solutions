terraform {
  required_version = ">= 1.9.0"

  backend "s3" {
    # Values injected via: terraform init -backend-config=backend.tfvars
    # Run setup/backend/state-backend.sh dr to create the backend resources
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
    tags = {
      Solution    = "anp-streaming-ai"
      Environment = "dr"
      ManagedBy   = "terraform"
      CostCenter  = "OPP-2025-001"
      Purpose     = "DisasterRecovery"
    }
  }
}
