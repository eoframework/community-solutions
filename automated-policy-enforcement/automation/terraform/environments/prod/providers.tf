terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    # Values injected via -backend-config=backend.tfvars at init time
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
  region = var.solution.region

  default_tags {
    tags = local.common_tags
  }
}

# DR / secondary region provider — required by cross-region modules
provider "aws" {
  alias  = "dr"
  region = var.solution.dr_region

  default_tags {
    tags = local.common_tags
  }
}
