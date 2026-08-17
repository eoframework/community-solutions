terraform {
  required_version = ">= 1.9.0"

  backend "s3" {
    # Populated via -backend-config flag at terraform init
    # Run setup/backend/state-backend.sh prod to create the backend resources
    # and generate the backend.tfvars file
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.project.region_primary

  default_tags {
    tags = {
      Solution         = var.solution.name
      SolutionAbbr     = var.solution.abbr
      Environment      = "prod"
      Region           = var.project.region_primary
      ManagedBy        = "terraform"
      Owner            = var.ownership.owner_team
      CostCenter       = var.ownership.cost_center
      ProjectCode      = var.ownership.project_code
      DataClassification = "Restricted"
    }
  }
}

# Secondary region provider for cross-region operations (us-east-2)
provider "aws" {
  alias  = "secondary"
  region = var.project.region_secondary

  default_tags {
    tags = {
      Solution         = var.solution.name
      SolutionAbbr     = var.solution.abbr
      Environment      = "prod"
      Region           = var.project.region_secondary
      ManagedBy        = "terraform"
      Owner            = var.ownership.owner_team
      CostCenter       = var.ownership.cost_center
      ProjectCode      = var.ownership.project_code
      DataClassification = "Restricted"
    }
  }
}
