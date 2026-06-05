#------------------------------------------------------------------------------
# Storage Module - Tier 2 Solution Module
# Composes S3 buckets for artifacts, guidance, and supporting stores
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Artifact S3 Bucket (raw MD/CSV + converted DOCX/PPTX/XLSX + Terraform bundles)
#------------------------------------------------------------------------------
module "artifact_bucket" {
  source = "../aws/s3"

  bucket_name             = var.storage.artifact_bucket_name
  versioning_enabled      = var.storage.artifact_bucket_versioning_enabled
  kms_key_arn             = var.kms_s3_key_arn
  lifecycle_rules_enabled = true
  standard_retention_days = var.storage.artifact_standard_retention_days
  glacier_retention_days  = var.storage.artifact_glacier_retention_days
  force_destroy           = var.force_destroy

  common_tags = var.common_tags
}

#------------------------------------------------------------------------------
# Guidance S3 Bucket (EO Framework guidance files for generation agents)
#------------------------------------------------------------------------------
module "guidance_bucket" {
  source = "../aws/s3"

  bucket_name             = var.storage.guidance_bucket_name
  versioning_enabled      = true
  kms_key_arn             = var.kms_s3_key_arn
  lifecycle_rules_enabled = false
  force_destroy           = var.force_destroy

  common_tags = var.common_tags
}
