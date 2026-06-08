#------------------------------------------------------------------------------
# Tier 2 — Security: KMS CMKs, Cognito User Pool, WAF ACL, GuardDuty,
# CloudTrail, IAM Access Analyzer, and application security groups
#------------------------------------------------------------------------------

#-- KMS Customer Managed Keys -------------------------------------------------

module "kms_catalog" {
  source = "../aws/kms"

  key_alias           = var.kms_catalog_cmk_alias
  description         = "CMK for catalog data (DynamoDB content-catalog table and S3 raw-catalog bucket)"
  enable_key_rotation = var.kms_rotation_enabled
  name_prefix         = var.name_prefix
  common_tags         = var.common_tags
}

module "kms_user_data" {
  source = "../aws/kms"

  key_alias           = var.kms_user_data_cmk_alias
  description         = "CMK for user data (user-profile and interaction-events DynamoDB tables)"
  enable_key_rotation = var.kms_rotation_enabled
  name_prefix         = var.name_prefix
  common_tags         = var.common_tags
}

module "kms_model_artifacts" {
  source = "../aws/kms"

  key_alias           = var.kms_model_artifacts_cmk_alias
  description         = "CMK for SageMaker model artifacts S3 bucket"
  enable_key_rotation = var.kms_rotation_enabled
  name_prefix         = var.name_prefix
  common_tags         = var.common_tags
}

#-- Application Security Group ------------------------------------------------

resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app-sg"
  description = "Security group for Lambda ENIs and SageMaker endpoint ENIs"
  vpc_id      = var.vpc_id

  egress {
    description = "All outbound - Lambda/SageMaker need HTTPS to AWS services"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-app-sg"
  })
}

#-- Cognito User Pool ---------------------------------------------------------

resource "aws_cognito_user_pool" "main" {
  name = "${var.name_prefix}-user-pool"

  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  mfa_configuration = var.cognito_mfa_enabled ? "OPTIONAL" : "OFF"

  dynamic "software_token_mfa_configuration" {
    for_each = var.cognito_mfa_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  auto_verified_attributes = ["email"]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-user-pool"
  })
}

# Store Cognito User Pool ID in SSM (no secrets, just a reference parameter)
resource "aws_ssm_parameter" "cognito_user_pool_id" {
  name        = "/${var.name_prefix}/cognito/user-pool-id"
  type        = "String"
  value       = aws_cognito_user_pool.main.id
  description = "Cognito User Pool ID for the ${var.name_prefix} environment"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-cognito-user-pool-id-param"
  })
}

#-- WAF v2 Web ACL (for API Gateway) ------------------------------------------

resource "aws_wafv2_web_acl" "api" {
  count = var.waf_enabled ? 1 : 0
  name  = "${var.name_prefix}-api-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-CRS"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-KBI"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-IPRep"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-waf"
    sampled_requests_enabled   = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-api-waf"
  })
}

#-- GuardDuty -----------------------------------------------------------------

resource "aws_guardduty_detector" "main" {
  count  = var.guardduty_enabled ? 1 : 0
  enable = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-guardduty"
  })
}

#-- CloudTrail ----------------------------------------------------------------

resource "aws_cloudwatch_log_group" "cloudtrail" {
  count             = var.cloudtrail_enabled ? 1 : 0
  name              = "/aws/cloudtrail/${var.name_prefix}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-cloudtrail-logs"
  })
}

#-- IAM Access Analyzer -------------------------------------------------------

resource "aws_accessanalyzer_analyzer" "main" {
  count         = var.iam_access_analyzer_enabled ? 1 : 0
  analyzer_name = "${var.name_prefix}-access-analyzer"
  type          = "ACCOUNT"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-access-analyzer"
  })
}
