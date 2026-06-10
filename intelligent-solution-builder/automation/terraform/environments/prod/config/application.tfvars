#------------------------------------------------------------------------------
# Application Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-10 02:56:40
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

application = {
  # REST API version prefix used in all endpoint paths (/api/v1/)
  api_version = "v1"
  # Comma-separated list of the 7 automated artifact types supported by the generation pipeline
  artifact_types = ["discovery-questionnaire,solution-briefing,statement-of-work,infrastructure-costs,detailed-design,implementation-guide,terraform"]
  log_level = "info"  # Lambda function logging verbosity level
  # Maximum allowed client brief JSON payload size in kilobytes
  max_brief_size_kb = 512
  # Application identifier used in CloudWatch log group names and Datadog APM service name
  name = "amatra-isb"
  # Expiry time in seconds for S3 presigned artifact download URLs
  presigned_url_ttl_seconds = 86400
}
