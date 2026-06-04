#------------------------------------------------------------------------------
# Tier 2 — Storage capability module
# Composes: aws/s3 (artifacts, guidance, cloudtrail), aws/ecr
#------------------------------------------------------------------------------

module "artifacts_bucket" {
  source                             = "../aws/s3"
  bucket_name                        = var.storage.artifacts_bucket_name
  versioning_enabled                 = var.storage.artifacts_versioning_enabled
  intelligent_tiering_days           = var.storage.artifacts_intelligent_tiering_days
  noncurrent_version_expiration_days = var.operations.backup_s3_version_retention_days
  force_destroy                      = false
  common_tags                        = var.common_tags
}

module "guidance_bucket" {
  source             = "../aws/s3"
  bucket_name        = var.storage.guidance_bucket_name
  versioning_enabled = true
  force_destroy      = false
  common_tags        = var.common_tags
}

module "ecr_repository" {
  source           = "../aws/ecr"
  repository_name  = var.storage.ecr_repository_name
  scan_on_push     = var.storage.ecr_image_scan_on_push
  common_tags      = var.common_tags
}
