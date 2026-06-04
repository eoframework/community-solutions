#------------------------------------------------------------------------------
# Storage Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-04 19:28:42
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  # Enable ECR vulnerability scanning on every image push to detect CVEs in eof-tools Python dependencies
  ecr_image_scan_on_push = true
  # ECR repository name for agent container images containing eof-tools library
  ecr_repository_name = "amatra-prod-ecr-eoframework-agent"
  # S3 bucket name for raw MD/CSV source artifacts and converted DOCX/PPTX/XLSX artifacts
  s3_artifacts_bucket_name = "amatra-prod-s3-artifacts-[aws-account-id]"
  # Days after which S3 objects transition to Intelligent-Tiering storage class
  s3_artifacts_intelligent_tiering_days = 90
  # S3 key prefix for converted DOCX/PPTX/XLSX artifacts produced by eof-tools converter pipeline
  s3_artifacts_prefix_converted = "converted/"
  # S3 key prefix for raw source markdown and CSV artifacts produced by generation agents
  s3_artifacts_prefix_raw = "raw/"
  # Enable S3 object versioning on the artifacts bucket to support recovery and immutable lineage
  s3_artifacts_versioning_enabled = true
  # S3 bucket containing EO Framework guidance files loaded by agents as prompt context
  s3_guidance_bucket_name = "amatra-prod-s3-guidance-[aws-account-id]"
  # S3 key prefix for Terraform IaC automation bundles produced by Code Generator agent
  s3_terraform_prefix = "terraform/"
}
