#------------------------------------------------------------------------------
# Operations Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-10 02:56:40
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

operations = {
  # CloudWatch Events cron expression for nightly Cognito user pool export to S3
  backup_cognito_export_schedule = "cron(0 2 * * ? *)"
  # DynamoDB PITR continuous backup window in days
  backup_dynamodb_pitr_window_days = 35
  # GitHub repository containing all Lambda source code and CloudFormation/SAM templates
  cicd_github_repo = "amatra/amatra-isb"
  # Lambda function alias name used for production traffic routing in blue-green deployments
  cicd_lambda_alias_prod = "$PROD"
  # Require manual GitHub Actions approval gate before deploying to Production environment
  cicd_production_approval_required = true
  # Duration in weeks of Phase 1 hypercare support period post-MVP go-live (target: 30 Sep 2026)
  hypercare_phase1_duration_weeks = 8
  # Duration in weeks of Phase 2 hypercare support period post-Phase 2 go-live (target: 15 Dec 2026)
  hypercare_phase2_duration_weeks = 4
  # Target QA first-pass acceptance rate percentage for generated artifacts
  qa_first_pass_target_pct = 90
  # API Gateway 5xx error rate percentage within 4 hours of cutover that triggers rollback
  rollback_trigger_5xx_pct = 5
  # Async job failure rate percentage within 4 hours of cutover that triggers automatic rollback
  rollback_trigger_job_failure_pct = 20
  # Default monthly global generation count limit across all users
  usage_limit_global_monthly_default = 240
  # Default monthly generation count limit per Amatra internal user
  usage_limit_per_user_monthly_default = 10
}
