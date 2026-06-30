terraform {
  required_version = ">= 1.9.0"

  backend "s3" {
    # Populated via -backend-config=backend.tfvars at init time.
    # Run setup/backend/state-backend.sh prod to create the S3 bucket
    # and DynamoDB table, then terraform init -backend-config=backend.tfvars
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.project.primary_region

  default_tags {
    tags = {
      Solution           = var.solution.name
      Environment        = "prod"
      Owner              = "amatra-delivery"
      CostCenter         = "MedCore-ClinicalApps-2026"
      DataClassification = "phi-restricted"
      Compliance         = "hipaa,soc2,hitech"
      CreatedBy          = "terraform"
      ManagedBy          = "amatra"
    }
  }
}

provider "aws" {
  alias  = "dr"
  region = var.project.dr_region

  default_tags {
    tags = {
      Solution           = var.solution.name
      Environment        = "prod-dr"
      Owner              = "amatra-delivery"
      CostCenter         = "MedCore-ClinicalApps-2026"
      DataClassification = "phi-restricted"
      Compliance         = "hipaa,soc2,hitech"
      CreatedBy          = "terraform"
      ManagedBy          = "amatra"
    }
  }
}
