#------------------------------------------------------------------------------
# Tier 2 — Security Module
# Composes: Cognito User Pool, WAF WebACL, GuardDuty, Security Hub
# SOC 2 CC6 / GDPR identity and access control layer
#------------------------------------------------------------------------------

# Cognito User Pool
resource "aws_cognito_user_pool" "this" {
  name = "${var.name_prefix}-users"

  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  mfa_configuration = var.cognito.mfa_enforcement

  software_token_mfa_configuration {
    enabled = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = true
    string_attribute_constraints {
      min_length = 5
      max_length = 254
    }
  }

  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  tags = var.common_tags
}

# Cognito App Client
resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.name_prefix}-app-client"
  user_pool_id = aws_cognito_user_pool.this.id

  access_token_validity  = var.cognito.token_expiry_minutes
  id_token_validity      = var.cognito.token_expiry_minutes
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  prevent_user_existence_errors = "ENABLED"
}

# Cognito Groups
resource "aws_cognito_user_group" "admin" {
  name         = var.cognito.admin_group_name
  user_pool_id = aws_cognito_user_pool.this.id
  description  = "Platform administrators with usage-limit override capability"
  precedence   = 1
}

resource "aws_cognito_user_group" "presales" {
  name         = var.cognito.presales_group_name
  user_pool_id = aws_cognito_user_pool.this.id
  description  = "Pre-sales consultants with access to Phase 1 artifact types"
  precedence   = 2
}

resource "aws_cognito_user_group" "delivery" {
  name         = var.cognito.delivery_group_name
  user_pool_id = aws_cognito_user_pool.this.id
  description  = "Delivery consultants with access to all 7 artifact types"
  precedence   = 3
}

# WAF WebACL — production only (disabled by enable_waf=false in test/dr)
resource "aws_wafv2_web_acl" "api" {
  count = var.enable_waf ? 1 : 0
  name  = "${var.name_prefix}-api-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # AWS Managed Rule Group — Core Rule Set
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
      metric_name                = "${var.name_prefix}-crs"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rule Group — Known Bad Inputs
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
      metric_name                = "${var.name_prefix}-kbi"
      sampled_requests_enabled   = true
    }
  }

  # Rate-based rule — per-IP throttle
  rule {
    name     = "${var.name_prefix}-rate-limit"
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.waf_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-waf"
    sampled_requests_enabled   = true
  }

  tags = var.common_tags
}

# GuardDuty (production only)
resource "aws_guardduty_detector" "this" {
  count  = var.enable_guardduty ? 1 : 0
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
  }

  tags = var.common_tags
}

# Security Hub
resource "aws_securityhub_account" "this" {
  count = var.enable_securityhub ? 1 : 0
}

resource "aws_securityhub_standards_subscription" "aws_foundational" {
  count         = var.enable_securityhub ? 1 : 0
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [aws_securityhub_account.this]
}

data "aws_region" "current" {}
