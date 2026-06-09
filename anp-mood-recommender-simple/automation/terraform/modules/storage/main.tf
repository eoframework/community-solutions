#------------------------------------------------------------------------------
# Storage Module (Tier 2) - S3 Catalog Bucket
# Calls: aws/s3
#------------------------------------------------------------------------------

module "catalog_bucket" {
  source = "../aws/s3"

  bucket_name             = var.bucket_name
  versioning_enabled      = var.versioning_enabled
  sse_algorithm           = "AES256"
  lambda_notification_arn = var.autotagger_lambda_arn
  notification_prefix     = var.catalog_prefix
  common_tags             = var.common_tags
}

resource "aws_lambda_permission" "s3_autotagger" {
  count = var.autotagger_lambda_arn != "" ? 1 : 0

  statement_id  = "AllowS3InvokeAutoTagger"
  action        = "lambda:InvokeFunction"
  function_name = var.autotagger_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.catalog_bucket.bucket_arn
}
