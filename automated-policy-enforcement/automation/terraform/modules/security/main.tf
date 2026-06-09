#------------------------------------------------------------------------------
# Tier 2: Security — SCPs (document), IAM Identity Center permission set
# documentation, and Secrets Manager placeholders for platform secrets.
# Secrets Manager secrets are created with placeholder values — actual
# secret values are injected at deploy time via the orchestrator or
# manual rotation; they are NEVER hard-coded here.
#
# IAM execution roles for Lambda functions are defined within each
# integration module (siem_integration, itsm_integration, etc.) to keep
# the IAM trust boundaries co-located with their consumers.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# IAM Role — AFT Pipeline execution role
#------------------------------------------------------------------------------
resource "aws_iam_role" "aft_pipeline" {
  name        = "${var.name_prefix}-aft-pipeline-role"
  description = "AFT account vending pipeline execution role — least privilege per design"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "codepipeline.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-aft-pipeline-role"
    Purpose = "aft-pipeline"
  })
}

#------------------------------------------------------------------------------
# Secrets Manager — placeholders for integration credentials
# Actual values are injected at deploy time; never stored in code
#------------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "siem_api_key" {
  name        = "${var.name_prefix}/siem/api-key"
  description = "Bearer token for Lambda-to-SIEM API authentication — rotated every ${var.credentials_rotation_days} days"
  kms_key_id  = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-siem-api-key"
    Purpose = "siem-integration"
    Rotate  = "true"
  })
}

resource "aws_secretsmanager_secret" "itsm_oauth_secret" {
  name        = "${var.name_prefix}/itsm/oauth-client-secret"
  description = "OAuth 2.0 client secret for Lambda-to-ITSM API authentication — rotated every ${var.credentials_rotation_days} days"
  kms_key_id  = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-itsm-oauth-secret"
    Purpose = "itsm-integration"
    Rotate  = "true"
  })
}

resource "aws_secretsmanager_secret" "saml_signing_cert" {
  name        = "${var.name_prefix}/sso/saml-signing-cert"
  description = "SAML 2.0 signing certificate PEM from on-premises IdP — update on IdP cert rotation"
  kms_key_id  = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-saml-signing-cert"
    Purpose = "sso-federation"
  })
}

resource "aws_secretsmanager_secret" "siem_api_endpoint" {
  name        = "${var.name_prefix}/siem/api-endpoint"
  description = "HTTPS endpoint for on-premises SIEM event ingestion API"
  kms_key_id  = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-siem-api-endpoint"
    Purpose = "siem-integration"
  })
}

resource "aws_secretsmanager_secret" "itsm_api_endpoint" {
  name        = "${var.name_prefix}/itsm/api-endpoint"
  description = "HTTPS endpoint for on-premises ITSM change-approval API"
  kms_key_id  = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-itsm-api-endpoint"
    Purpose = "itsm-integration"
  })
}

resource "aws_secretsmanager_secret" "itsm_oauth_client_id" {
  name        = "${var.name_prefix}/itsm/oauth-client-id"
  description = "OAuth 2.0 client ID for Lambda-to-ITSM API authentication"
  kms_key_id  = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-itsm-oauth-client-id"
    Purpose = "itsm-integration"
  })
}
