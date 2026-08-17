#------------------------------------------------------------------------------
# Operations Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-08-17 00:33:59
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

finops = {
  # Default monthly budget amount in USD applied to each new workload account via AFT
  budgets_monthly_threshold_usd = 3000
  # Enable AWS Cost Anomaly Detection for automatic spend anomaly identification
  cost_anomaly_detection_enabled = true
  # Enable AWS Cost Explorer at the organisation level for consolidated billing visibility
  cost_explorer_enabled = true
}

operations = {
  # Maximum number of users in IAM Identity Center covered under the no-charge tier
  account_count_iam_identity_center_users = 50
  # Target number of AWS accounts to be provisioned and enrolled at go-live
  account_count_target_go_live = 12
  # Estimated CloudTrail event volume per month (organisation trail; both regions) used for cost modelling
  cloudtrail_events_per_month_estimate = 100000000
  # Duration in weeks of post-go-live hypercare support provided by the vendor team
  hypercare_duration_weeks = 4
  # Maximum response time in hours for P1 (Critical) issues during hypercare
  hypercare_p1_response_sla_hours = 2
  # Maximum response time in hours for P2 (High) issues during hypercare (business hours)
  hypercare_p2_response_sla_hours = 4
  # Minimum percentage of infrastructure managed via Terraform and AFT (no manual console changes)
  iac_coverage_target_percent = 95
  # Estimated log storage ingestion in GB per month across all log types for capacity and cost planning
  log_storage_gb_per_month_estimate = 500
}
