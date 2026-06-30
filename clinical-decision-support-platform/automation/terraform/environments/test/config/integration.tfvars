#------------------------------------------------------------------------------
# Integration Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-30 01:10:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

integration = {
  # Epic CDS Hooks 2.0 callback URL for writing risk score alerts back to the Epic workflow
  epic_cds_hooks_callback_url = "[epic-cds-hooks-callback-url]"  # TODO: Replace with actual value
  # Epic FHIR R4 API base URL for SMART on FHIR subscription events
  epic_fhir_base_url = "[epic-fhir-base-url]"  # TODO: Replace with actual value
  # Comma-separated list of FHIR R4 resource types for Epic subscription events
  epic_fhir_subscription_resources = ["Observation,Encounter,MedicationRequest,DiagnosticReport"]
  # Epic SMART on FHIR OAuth 2.0 token endpoint URL for FHIR connector authentication
  epic_oauth_token_url = "[epic-oauth-token-url]"  # TODO: Replace with actual value
  # Timeout in milliseconds for Epic FHIR API calls from the Lambda connector
  epic_timeout_ms = 10000
  # Mirth Connect integration engine endpoint URL accessed via PrivateLink from AWS
  mirth_endpoint_url = "[mirth-endpoint-url]"  # TODO: Replace with actual value
  # Comma-separated HL7 v2.3 message types consumed from Mirth Connect
  mirth_hl7_message_types = ["ADT_A01,ADT_A03,ADT_A08,ORU_R01"]
  # On-premises SQL Server 2016 data warehouse JDBC endpoint for nightly readmission export
  sql_server_endpoint = "[sql-server-endpoint]"  # TODO: Replace with actual value
  # Cron expression for nightly readmission outcome export Lambda to on-premises SQL Server 2016
  sql_server_export_schedule_cron = "cron(0 7 * * ? *)"
}
