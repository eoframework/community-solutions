################################################################################
# Tier 2 — Security Module
# Creates all KMS CMKs (one per data store), WAF WebACL, IAM Access Analyzer,
# and CloudTrail (HIPAA audit logging).
################################################################################

# ---------------------------------------------------------------------------
# KMS CMKs — one per data store for blast-radius isolation
# ---------------------------------------------------------------------------
module "kms_healthlake" {
  source = "../aws/kms"

  name_prefix      = var.name_prefix
  key_alias_suffix = "healthlake"
  description      = "CMK for Amazon HealthLake PHI FHIR datastore — ${var.name_prefix}"
  multi_region     = var.multi_region_keys

  common_tags = var.common_tags
}

module "kms_aurora" {
  source = "../aws/kms"

  name_prefix      = var.name_prefix
  key_alias_suffix = "aurora"
  description      = "CMK for RDS Aurora PostgreSQL — ${var.name_prefix}"
  multi_region     = var.multi_region_keys

  common_tags = var.common_tags
}

module "kms_s3_datalake" {
  source = "../aws/kms"

  name_prefix      = var.name_prefix
  key_alias_suffix = "s3-datalake"
  description      = "CMK for S3 data lake buckets (HL7 archive + ML artefacts) — ${var.name_prefix}"
  multi_region     = var.multi_region_keys

  common_tags = var.common_tags
}

module "kms_s3_audit" {
  source = "../aws/kms"

  name_prefix      = var.name_prefix
  key_alias_suffix = "s3-audit"
  description      = "CMK for S3 CloudTrail audit log delivery bucket — ${var.name_prefix}"
  multi_region     = var.multi_region_keys

  common_tags = var.common_tags
}

module "kms_elasticache" {
  source = "../aws/kms"

  name_prefix      = var.name_prefix
  key_alias_suffix = "elasticache"
  description      = "CMK for ElastiCache Redis patient feature vectors — ${var.name_prefix}"
  multi_region     = var.multi_region_keys

  common_tags = var.common_tags
}

module "kms_ebs" {
  source = "../aws/kms"

  name_prefix      = var.name_prefix
  key_alias_suffix = "ebs"
  description      = "CMK for EBS volumes (MSK brokers + SageMaker) — ${var.name_prefix}"
  multi_region     = var.multi_region_keys

  common_tags = var.common_tags
}

# ---------------------------------------------------------------------------
# CloudTrail — HIPAA PHI audit logging (7-year WORM)
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "cloudtrail" {
  count             = var.enable_cloudtrail ? 1 : 0
  name              = "/aws/cloudtrail/${var.name_prefix}"
  retention_in_days = 90
  kms_key_id        = module.kms_s3_audit.key_arn

  tags = var.common_tags
}

resource "aws_iam_role" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0
  name  = "${var.name_prefix}-cloudtrail-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "cloudtrail_logs" {
  count = var.enable_cloudtrail ? 1 : 0
  name  = "${var.name_prefix}-cloudtrail-logs-policy"
  role  = aws_iam_role.cloudtrail[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*"
    }]
  })
}

# ---------------------------------------------------------------------------
# WAF WebACL — OWASP + AWS Managed Rules
# ---------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "this" {
  count = var.enable_waf ? 1 : 0
  name  = "${var.name_prefix}-waf-acl"
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
      metric_name                = "${var.name_prefix}-waf-common"
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
      metric_name                = "${var.name_prefix}-waf-bad-inputs"
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
      metric_name                = "${var.name_prefix}-waf-ip-rep"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-waf"
    sampled_requests_enabled   = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-waf-acl"
  })
}

# WAF logging
resource "aws_cloudwatch_log_group" "waf" {
  count             = var.enable_waf ? 1 : 0
  name              = "aws-waf-logs-${var.name_prefix}"
  retention_in_days = 90

  tags = var.common_tags
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count                   = var.enable_waf ? 1 : 0
  log_destination_configs = [aws_cloudwatch_log_group.waf[0].arn]
  resource_arn            = aws_wafv2_web_acl.this[0].arn
}

# ---------------------------------------------------------------------------
# IAM Access Analyzer
# ---------------------------------------------------------------------------
resource "aws_accessanalyzer_analyzer" "this" {
  count         = var.enable_access_analyzer ? 1 : 0
  analyzer_name = "${var.name_prefix}-access-analyzer"
  type          = "ACCOUNT"

  tags = var.common_tags
}

# ---------------------------------------------------------------------------
# GuardDuty
# ---------------------------------------------------------------------------
resource "aws_guardduty_detector" "this" {
  count  = var.enable_guardduty ? 1 : 0
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = false
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  tags = var.common_tags
}

# ---------------------------------------------------------------------------
# Security Hub
# ---------------------------------------------------------------------------
resource "aws_securityhub_account" "this" {
  count                        = var.enable_security_hub ? 1 : 0
  enable_default_standards     = true
  auto_enable_controls         = true
  control_finding_generator    = "SECURITY_CONTROL"
}

# ---------------------------------------------------------------------------
# Macie — PHI data classification in S3
# ---------------------------------------------------------------------------
resource "aws_macie2_account" "this" {
  count                        = var.enable_macie ? 1 : 0
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = "ENABLED"
}
