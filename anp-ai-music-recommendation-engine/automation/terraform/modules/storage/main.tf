#------------------------------------------------------------------------------
# Tier 2 — Storage: S3 buckets for raw catalog, transcripts, features,
# model artifacts, and CloudTrail audit logs
#------------------------------------------------------------------------------

module "raw_catalog" {
  source = "../aws/s3"

  bucket_name         = var.raw_catalog_bucket
  versioning_enabled  = var.versioning_enabled
  kms_key_arn         = var.catalog_kms_key_arn
  lifecycle_ia_days   = var.lifecycle_ia_days
  lifecycle_glacier_days = var.lifecycle_glacier_days
  name_prefix         = var.name_prefix
  common_tags         = var.common_tags
}

module "transcripts" {
  source = "../aws/s3"

  bucket_name         = var.transcripts_bucket
  versioning_enabled  = var.versioning_enabled
  kms_key_arn         = var.catalog_kms_key_arn
  lifecycle_ia_days   = var.lifecycle_ia_days
  lifecycle_glacier_days = var.lifecycle_glacier_days
  name_prefix         = var.name_prefix
  common_tags         = var.common_tags
}

module "features" {
  source = "../aws/s3"

  bucket_name         = var.features_bucket
  versioning_enabled  = var.versioning_enabled
  kms_key_arn         = var.catalog_kms_key_arn
  lifecycle_ia_days   = var.lifecycle_ia_days
  lifecycle_glacier_days = var.lifecycle_glacier_days
  name_prefix         = var.name_prefix
  common_tags         = var.common_tags
}

module "models" {
  source = "../aws/s3"

  bucket_name         = var.models_bucket
  versioning_enabled  = var.versioning_enabled
  kms_key_arn         = var.model_kms_key_arn
  lifecycle_ia_days   = var.lifecycle_ia_days
  lifecycle_glacier_days = var.lifecycle_glacier_days
  name_prefix         = var.name_prefix
  common_tags         = var.common_tags
}

module "cloudtrail_logs" {
  source = "../aws/s3"

  bucket_name         = var.cloudtrail_bucket
  versioning_enabled  = true
  kms_key_arn         = var.catalog_kms_key_arn
  # No lifecycle tiering for CloudTrail — Object Lock governs retention
  lifecycle_ia_days      = 0
  lifecycle_glacier_days = 0
  name_prefix         = var.name_prefix
  common_tags         = var.common_tags
}
