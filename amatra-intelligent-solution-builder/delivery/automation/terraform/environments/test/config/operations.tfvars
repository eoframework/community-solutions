#------------------------------------------------------------------------------
# Operations Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 16:27:28
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

cicd = {
  # CodeBuild compute type for agent image build and smoke test
  codebuilld_compute_type = "BUILD_GENERAL1_SMALL"
  # CodePipeline name for Docker image build and ECR push workflow
  codepipeline_name = "amatra-dev-pipeline"
  # Enforce terraform validate as a CI syntax gate in CodeBuild
  terraform_validate_gate = true
}

operations = {
  # Enable automated DynamoDB and S3 backup procedures
  backup_enabled = false
  # Post-go-live hypercare support period in weeks
  hypercare_weeks = 0
  # EventBridge cron expression for monthly quota counter reset Lambda
  quota_reset_schedule = "cron(0 0 1 * ? *)"
  # Recovery Point Objective in hours for DynamoDB data
  rpo_hours = 24
  # Recovery Time Objective in hours for full platform restoration
  rto_hours = 4
  # Maximum Lambda concurrency limit across all platform functions
  scaling_max_lambda_concurrency = 10
  # Minimum Lambda concurrency (reserved) per function
  scaling_min_lambda_concurrency = 1
}
