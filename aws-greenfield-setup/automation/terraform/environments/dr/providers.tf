terraform {
  required_version = ">= 1.9.0"

  backend "s3" {
    # Populated via -backend-config flag at terraform init
    # Run setup/backend/state-backend.sh dr to create the backend resources
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# DR primary provider — us-east-2 (DR region)
provider "aws" {
  region = var.project.region_primary

  default_tags {
    tags = {
      Solution           = var.solution.name
      SolutionAbbr       = var.solution.abbr
      Environment        = "dr"
      Region             = var.project.region_primary
      ManagedBy          = "terraform"
      Owner              = var.ownership.owner_team
      CostCenter         = var.ownership.cost_center
      ProjectCode        = var.ownership.project_code
      DataClassification = "Restricted"
      Purpose            = "DisasterRecovery"
    }
  }
}

# Secondary provider points back to us-east-1 (prod primary) for cross-region ops
provider "aws" {
  alias  = "secondary"
  region = var.project.region_secondary

  default_tags {
    tags = {
      Solution           = var.solution.name
      SolutionAbbr       = var.solution.abbr
      Environment        = "dr"
      Region             = var.project.region_secondary
      ManagedBy          = "terraform"
      Owner              = var.ownership.owner_team
      CostCenter         = var.ownership.cost_center
      ProjectCode        = var.ownership.project_code
      DataClassification = "Restricted"
      Purpose            = "DisasterRecovery"
    }
  }
}
