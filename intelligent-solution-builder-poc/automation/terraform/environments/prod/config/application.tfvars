#------------------------------------------------------------------------------
# Application Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-11 15:01:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

application = {
  # Comma-separated list of the 7 artifact types supported by the generation pipeline per SOW scope
  artifact_types = ["discovery-questionnaire,solution-briefing,statement-of-work,infrastructure-costs,level-of-effort-estimate,detailed-design,terraform-automation"]
  # Maximum allowed duration for a single generation workflow before it is marked as timed out
  job_timeout_minutes = 90
  # Logging verbosity for all Lambda functions using AWS Lambda Powertools Logger
  log_level = "info"
  # Maximum number of concurrent Step Functions generation workflows permitted simultaneously
  max_concurrent_jobs = 10
  # Application identifier used in CloudWatch log group names and Datadog service tagging
  name = "amatra-intelligent-solution-builder"
  # Expiry time in seconds for S3 pre-signed artifact download URLs returned by the Artifact Retrieval Lambda
  presigned_url_expiry_seconds = 3600
  # Deployed application version injected into Lambda environment variables for health-check responses
  version = "1.0.0"
}
