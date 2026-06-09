#------------------------------------------------------------------------------
# Operations Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 21:41:31
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

operations = {
  # Enable AWS Backup cross-region replication to ap-southeast-4 DR region
  backup_dr_replication_enabled = true
  # AWS Backup plan name covering DynamoDB and S3 configuration buckets
  backup_plan_name = "cntso-platform-backup-prod"
  # Backup retention period in days for AWS Backup daily plan
  backup_retention_days = 30
  # Number of days before Q2 2026 regulatory review during which a change freeze is enforced
  change_freeze_pre_review_days = 14
  # Phase deliverable in which the ISO 27001 compliance evidence package is compiled and delivered
  compliance_evidence_package_schedule = "Phase3"
  # Minutes of governance evidence collection failure before DR activation is triggered
  dr_failover_activation_criteria_minutes = 30
  # Recovery Point Objective in hours for governance platform DR failover
  dr_rpo_hours = 1
  # Recovery Time Objective in hours for governance platform DR failover
  dr_rto_hours = 4
  # Duration of post-go-live hypercare support period in weeks
  hypercare_duration_weeks = 8
  # Maximum response time in hours for P1 (platform outage or compliance-blocking) issues during hypercare
  hypercare_p1_response_hours = 2
  # Patch Manager patching baseline schedule frequency for any platform instances
  patch_baseline_schedule = "monthly"
  # Platform availability target percentage for governance services per SOW SLA
  platform_availability_target = "99.9"
}
