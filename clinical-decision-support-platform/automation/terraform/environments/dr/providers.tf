terraform {
  required_version = ">= 1.9.0"

  backend "s3" {
    # Populated via -backend-config=backend.tfvars at init time.
    # Run setup/backend/state-backend.sh dr to create the backend resources
    # in the DR region (us-west-2).
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
      Environment        = "dr"
      Owner              = "amatra-delivery"
      CostCenter         = "MedCore-ClinicalApps-2026"
      DataClassification = "phi-restricted"
      Compliance         = "hipaa,soc2,hitech"
      Purpose            = "DisasterRecovery"
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
      Environment        = "dr"
      Owner              = "amatra-delivery"
      CostCenter         = "MedCore-ClinicalApps-2026"
      DataClassification = "phi-restricted"
      Compliance         = "hipaa,soc2,hitech"
      Purpose            = "DisasterRecovery"
      CreatedBy          = "terraform"
      ManagedBy          = "amatra"
    }
  }
}
