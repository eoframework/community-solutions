#------------------------------------------------------------------------------
# Operations Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-04 19:28:42
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

operations = {
  # DynamoDB PITR retention window in days; 35 is AWS maximum and required to meet RPO targets
  backup_dynamodb_pitr_recovery_window_days = 35
  # Number of days to retain non-current S3 object versions before permanent deletion
  backup_s3_version_retention_days = 365
  # AWS CodeBuild project name for the multi-stage Docker agent image build and ECR push pipeline
  codebuild_agent_image_project_name = "amatra-prod-codebuild-agent-image"
  # AWS CodeBuild project name for terraform plan gate executed before pull request merge to main
  codebuild_terraform_plan_project_name = "amatra-prod-codebuild-tf-plan"
  # Number of CLI smoke test commands executed during production cutover go/no-go decision gate
  cutover_smoke_test_commands_count = 5
  # Day of week for production cutover and maintenance windows (Pacific Time)
  cutover_window_day = "Tuesday"
  # Post-go-live hypercare support period duration in weeks
  hypercare_duration_weeks = 4
  # Maximum response time in hours for Severity 1 (platform down) incidents during hypercare
  hypercare_severity1_response_hours = 2
  # Aggregate reserved concurrency allocated across all platform Lambda functions
  scaling_lambda_reserved_concurrency_total = 200
  # AWS Systems Manager Parameter Store path for runtime DynamoDB Solutions table name lookup
  ssm_dynamodb_solutions_table_param = "/amatra/prod/dynamodb/solutions-table-name"
  # AWS Systems Manager Parameter Store path for runtime S3 artifacts bucket name lookup by Lambda functions
  ssm_s3_artifacts_bucket_param = "/amatra/prod/s3/artifacts-bucket-name"
  # S3 bucket name for Terraform remote state storage with DynamoDB state locking
  terraform_state_bucket_name = "amatra-prod-s3-tfstate-[aws-account-id]"
  # DynamoDB table name for Terraform state locking to prevent concurrent apply conflicts
  terraform_state_lock_table_name = "amatra-prod-ddb-tfstate-lock"
  # Terraform workspace name for production environment provisioning
  terraform_workspace_prod = "prod"
}

quota = {
  # Percentage of global monthly quota consumed before a CloudWatch alarm fires to notify Marcus Patel
  global_alert_threshold_pct = 90
  # Maximum total solutions generated globally per calendar month enforced atomically in DynamoDB
  global_monthly_solution_limit = 1000
  # Per-user solution count threshold at which a CloudWatch alarm fires to notify the operations team
  user_alert_threshold_count = 8
  # Maximum number of solutions a single user may generate per calendar month
  user_monthly_solution_limit = 10
}
