#------------------------------------------------------------------------------
# Dr Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-08-17 00:33:59
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

dr = {
  # Recovery Point Objective in minutes for Log Archive S3 data via cross-region replication
  rpo_log_archive_minutes = 15
  # Recovery Time Objective in hours for IAM Identity Center SSO (AWS-managed service SLA)
  rto_iam_identity_center_hours = 2
  # Recovery Time Objective in hours for full landing zone restoration from Terraform state
  rto_landing_zone_hours = 4
  # Recovery Time Objective in minutes for Network Firewall AZ failover via TGW re-routing
  rto_network_firewall_minutes = 30
}
