#------------------------------------------------------------------------------
# Operations Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-30 01:10:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

operations = {
  # Frequency in days of access review for Cognito role assignments and IAM policies
  access_review_cadence_days = 60
  # Minutes within which duplicate alerts of the same type for the same patient are suppressed
  alert_duplicate_suppression_minutes = 30
  # RDS Aurora automated snapshot retention in days
  backup_aurora_retention_days = 35
  # ElastiCache Redis automatic daily snapshot retention in days
  backup_elasticache_retention_days = 7
  # Redshift automated snapshot retention in days for outcomes analytics warehouse
  backup_redshift_retention_days = 7
  # AWS CodePipeline pipeline name for application and SageMaker model endpoint deployments
  ci_cd_pipeline_name = "medcore-cds-prod-deploy"
  # P95 latency threshold in milliseconds that triggers automatic CI/CD rollback within 30 minutes of deployment
  ci_cd_rollback_latency_threshold_ms = 3000
  # Enable Snyk container security scanning in CI/CD pipeline for ECS workloads
  ci_cd_snyk_scanning_enabled = true
  # Monthly active clinical users across all facilities (nurses + physicians + administrators)
  clinical_users_mau = 4200
  # Maximum hours to remediate a Critical AWS Config non-compliant finding per governance SLA
  compliance_config_remediation_critical_hours = 24
  # Maximum days to remediate a High AWS Config non-compliant finding per governance SLA
  compliance_config_remediation_high_days = 7
  # Frequency of scheduled regional failover DR drills to validate RTO and RPO targets
  dr_failover_test_schedule = "annual"
  # Recovery Point Objective in minutes for maximum acceptable data loss in regional failover
  dr_rpo_minutes = 15
  # Recovery Time Objective in hours for regional failover to passive DR region (us-west-2)
  dr_rto_hours = 4
  # Number of hospitals in scope for CDS Platform rollout per SOW engagement scope
  facility_count = 18
  # Post-GA hypercare support duration in weeks with 1-hour Critical incident response SLA
  hypercare_duration_weeks = 8
  # SageMaker endpoint CPU utilization percentage threshold triggering auto-scale-out
  scaling_sagemaker_cpu_threshold_pct = 70
}
