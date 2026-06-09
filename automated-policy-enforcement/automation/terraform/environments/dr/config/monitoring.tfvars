#------------------------------------------------------------------------------
# Monitoring Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 21:41:31
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

monitoring = {
  # SNS topic ARN routing P1 and P2 CloudWatch alarms to the on-call platform engineer
  cloudwatch_alert_sns_topic_arn = "[sns-topic-arn]"  # TODO: Replace with actual value
  # CloudWatch dashboard name for S3 CRR lag and DR region replication health
  cloudwatch_dashboard_dr = "cntso-dr-replication-dr"
  # CloudWatch dashboard name for IAM Identity Center login events and break-glass usage
  cloudwatch_dashboard_identity = "cntso-identity-access-dr"
  # CloudWatch dashboard name for AFT pipeline health and Config compliance trend
  cloudwatch_dashboard_platform_ops = "cntso-platform-operations-dr"
  # CloudWatch Logs retention in days before log group expiry; S3 export extends to 12 months
  cloudwatch_log_retention_days = 90
  # Maximum acceptable time from resource change to Config rule evaluation firing in seconds
  config_evaluation_lag_seconds = 60
  # Approximate number of AWS Config rules deployed (ISO 27001 conformance pack + internal baseline)
  config_rule_count = 80
  # Enable GuardDuty organisational detector in the Audit account for all member accounts
  guardduty_org_detector_enabled = true
  # Expected Security Hub finding volume per month used for Lambda concurrency and SIEM sizing
  securityhub_finding_volume_monthly = 1000
  # Enable AWS Foundational Security Best Practices standard in Security Hub
  securityhub_standards_aws_fsbp = true
  # Enable CIS AWS Foundations Benchmark standard in Security Hub
  securityhub_standards_cis = true
}
