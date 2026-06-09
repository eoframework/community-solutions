#------------------------------------------------------------------------------
# Integration Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 21:41:31
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

integration = {
  # HTTPS endpoint for the on-premises ITSM ticketing platform change-approval API
  itsm_api_endpoint = "[itsm-api-endpoint]"  # TODO: Replace with actual value
  # Interval in seconds at which the AFT pipeline polls ITSM for change record approval status
  itsm_approval_poll_interval_seconds = 120
  # Enable SCP condition that denies AFT pipeline execution without approved ITSM change record during change freeze
  itsm_change_freeze_scp_condition = true
  # OAuth 2.0 client ID for authenticating Lambda-to-ITSM API calls
  itsm_oauth_client_id = "[itsm-oauth-client-id]"  # TODO: Replace with actual value
  # SECRET (OAuth 2.0 client secret for ITSM API authentication): inject via Secrets Manager / SSM at deploy time
  itsm_oauth_client_secret = "SET_VIA_SECRETS_MANAGER"
  # HTTPS endpoint for the on-premises SIEM event ingestion API used by the forwarding Lambda
  siem_api_endpoint = "[siem-api-endpoint]"  # TODO: Replace with actual value
  # SECRET (Bearer token for authenticating Lambda-to-SIEM API calls): inject via Secrets Manager / SSM at deploy time
  siem_api_key = "SET_VIA_SECRETS_MANAGER"
  # Maximum acceptable end-to-end latency from Security Hub finding to SIEM ingestion in minutes
  siem_delivery_sla_minutes = 5
  # SQS DLQ message count threshold above which a P1 CloudWatch alarm fires
  siem_dlq_alarm_threshold = 0
  # SQS dead-letter queue name for failed SIEM forwarding Lambda invocations
  siem_dlq_name = "cntso-siem-forward-dlq-prod"
  # Minimum Security Hub finding severity forwarded to SIEM (CRITICAL, HIGH, MEDIUM, LOW, INFORMATIONAL)
  siem_finding_severity_threshold = "HIGH"
}
