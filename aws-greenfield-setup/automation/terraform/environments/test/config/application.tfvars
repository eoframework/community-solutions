#------------------------------------------------------------------------------
# Application Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-08-17 00:33:59
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

aft = {
  # AWS Budgets percentage threshold for the second (full) spend alert sent to all account owners
  customisation_budgets_alert_threshold_100 = 100
  # AWS Budgets percentage threshold for the first spend alert sent to all account owners
  customisation_budgets_alert_threshold_80 = 80
  # Mandatory tag key for cost allocation applied to all resources via AFT
  customisation_mandatory_tags_cost_center_key = "CostCenter"
  # Mandatory tag key for data sensitivity classification applied to all resources via AFT
  customisation_mandatory_tags_data_classification_key = "DataClassification"
  # Mandatory tag key for environment classification applied to all resources via AFT
  customisation_mandatory_tags_environment_key = "Environment"
  # Mandatory tag key for team ownership applied to all resources via AFT
  customisation_mandatory_tags_owner_key = "Owner"
  # Mandatory tag key for project identification applied to all resources via AFT
  customisation_mandatory_tags_project_key = "Project"
  # VCS repository URL for AFT account request Terraform configuration files
  pipeline_account_request_repo = "[aft-account-request-repo-url]"  # TODO: Replace with actual value
  # AWS CodeBuild compute type for AFT account vending and customisation stages
  pipeline_codebuild_compute_type = "BUILD_GENERAL1_SMALL"
  # Maximum number of concurrent AFT account vending pipelines permitted
  pipeline_max_concurrent_vending = 2
  # Terraform version pinned for all AFT pipeline executions
  pipeline_terraform_version = "1.9.0"
  # Maximum time in minutes for a complete AFT account vending run including all customisations
  pipeline_vending_sla_minutes = 30
}

cicd = {
  # Enable branch protection rules on the IaC VCS repository requiring peer review before merge
  pipeline_branch_protection_enabled = true
  # Require dual approval (Vendor Architect + Client Security Lead) for SCP changes
  pipeline_scp_dual_approval_required = false
  # Require a successful terraform plan validation as a CI/CD gate before any merge to main
  pipeline_terraform_plan_gate_enabled = true
}

terraform_cloud = {
  # HashiCorp Terraform Cloud organisation name for the client's Team tier account
  organisation_name = "[tf-cloud-org]"  # TODO: Replace with actual value
  # SECRET (Terraform Cloud Team API token injected into AFT CodePipeline at runtime): inject via Secrets Manager / SSM at deploy time
  team_token = "SET_VIA_SECRETS_MANAGER"
  # Prefix for all Terraform Cloud workspace names following ins-{purpose}-{region-short} convention
  workspace_prefix = "ins"
}
