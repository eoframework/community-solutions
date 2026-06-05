#------------------------------------------------------------------------------
# Operations Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-05 19:11:53
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

operations = {
  # Minimum artifact validation first-attempt pass rate across all 12 artifact types per SOW
  artifact_pass_rate_target_pct = "95"
  # Monthly API availability target as a percentage per SOW success metrics
  availability_target_pct = "99.5"
  # Enable automated DynamoDB PITR and S3 versioning backups across all environments
  backup_enabled = true
  # CI/CD pipeline tool for Docker build / ECR push / Lambda deploy / terraform validate gate
  cicd_pipeline_tool = "github-actions"
  # Post-go-live hypercare support period duration in weeks per SOW Handover section
  hypercare_duration_weeks = 0
  # Require peer review of terraform plan output before terraform apply per SOW governance
  peer_review_required = true
  # Zero quota bypass incidents permitted; enforced via atomic DynamoDB conditional writes
  quota_bypass_incidents_target = 0
  # Recovery Point Objective in hours; met by DynamoDB PITR continuous backup per SOW DR design
  rpo_hours = 1
  # Recovery Time Objective in hours; validated by DynamoDB PITR restore test in Phase 3
  rto_hours = 4
  # Global quota cap defining maximum monthly platform throughput
  scaling_max_solutions_monthly = 100
  # Minimum monthly solution volume sizing baseline used for infrastructure cost model
  scaling_min_solutions_monthly = 10
  # Enforce terraform validate syntax gate in CI/CD pipeline before terraform apply
  terraform_validate_gate = true
}
