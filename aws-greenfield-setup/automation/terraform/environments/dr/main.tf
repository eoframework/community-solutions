#------------------------------------------------------------------------------
# AWS Multi-Account Landing Zone — DR Environment
# Provider: AWS | Region: us-east-2 (DR primary) | Mirrors production posture
# DR mirrors prod: full SCPs including RCP, same retention, full monitoring
#------------------------------------------------------------------------------

locals {
  environment = "dr"
  name_prefix = "${var.solution.abbr}-${local.environment}"

  env_display_name = {
    prod = "Production"
    test = "Test"
    dr   = "Disaster Recovery"
  }

  project = {
    name        = var.solution.abbr
    environment = local.environment
  }

  common_tags = {
    Solution         = var.solution.name
    SolutionAbbr     = var.solution.abbr
    Environment      = local.environment
    Region           = var.project.region_primary
    ManagedBy        = "terraform"
    Owner            = var.ownership.owner_team
    CostCenter       = var.ownership.cost_center
    ProjectCode      = var.ownership.project_code
    DataClassification = "Restricted"
    Purpose          = "DisasterRecovery"
  }

  # Full SCP/RCP set — DR mirrors production governance posture
  scp_deny_root = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyRootAccountActions"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = ["arn:aws:iam::*:root"]
          }
        }
      }
    ]
  })

  scp_restrict_regions = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyNonApprovedRegions"
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = ["us-east-1", "us-east-2"]
          }
          ArnNotLike = {
            "aws:PrincipalARN" = [
              "arn:aws:iam::*:role/AWSControlTowerExecution",
              "arn:aws:iam::*:role/stacksets-exec-*"
            ]
          }
        }
      }
    ]
  })

  scp_lock_cloudtrail = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyCloudTrailModification"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "cloudtrail:UpdateTrail",
          "cloudtrail:PutEventSelectors"
        ]
        Resource = "*"
      }
    ]
  })

  scp_lock_config = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyConfigModification"
        Effect = "Deny"
        Action = [
          "config:DeleteConfigRule",
          "config:DeleteConfigurationRecorder",
          "config:DeleteDeliveryChannel",
          "config:StopConfigurationRecorder"
        ]
        Resource = "*"
      }
    ]
  })

  scp_require_mfa = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyWithoutMFA"
        Effect = "Deny"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })

  rcp_data_perimeter = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceOrgDataPerimeter"
        Effect = "Deny"
        Principal = { AWS = "*" }
        Action   = ["s3:*"]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:PrincipalOrgID" = var.aws_org.id
          }
          BoolIfExists = {
            "aws:PrincipalIsAWSService" = "false"
          }
        }
      }
    ]
  })

  permission_sets = {
    platform_admin = {
      name             = "PlatformAdministratorAccess"
      description      = "Full access to platform accounts"
      session_duration = "PT${var.sso.session_duration_hours}H"
    }
    security_auditor = {
      name             = "SecurityAuditorAccess"
      description      = "Read-only compliance and security investigation access"
      session_duration = "PT${var.sso.session_duration_hours}H"
    }
    network_operator = {
      name             = "NetworkOperatorAccess"
      description      = "Network access scoped to Network Hub account"
      session_duration = "PT${var.sso.session_duration_hours}H"
    }
    finops = {
      name             = "FinOpsAccess"
      description      = "Billing and Cost Explorer read access"
      session_duration = "PT${var.sso.session_duration_hours}H"
    }
  }

  managed_policy_attachments = {
    platform_admin = {
      permission_set_key = "platform_admin"
      managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
    }
    security_auditor_ro = {
      permission_set_key = "security_auditor"
      managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
    }
    security_auditor_audit = {
      permission_set_key = "security_auditor"
      managed_policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
    }
    network_operator = {
      permission_set_key = "network_operator"
      managed_policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
    }
    finops_billing = {
      permission_set_key = "finops"
      managed_policy_arn = "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#===============================================================================
# FOUNDATION — Full governance posture (DR mirrors production)
#===============================================================================
module "governance" {
  source = "../../modules/governance"

  organizational_units = {
    security = {
      name      = "Security"
      parent_id = var.aws_org.root_id
    }
    infrastructure = {
      name      = "Infrastructure"
      parent_id = var.aws_org.root_id
    }
    workloads_prod = {
      name      = "Workloads-Prod"
      parent_id = var.aws_org.root_id
    }
    workloads_nonprod = {
      name      = "Workloads-NonProd"
      parent_id = var.aws_org.root_id
    }
    sandbox = {
      name      = "Sandbox"
      parent_id = var.aws_org.root_id
    }
    suspended = {
      name      = "Suspended"
      parent_id = var.aws_org.root_id
    }
  }

  policies = {
    deny_root = {
      name        = "${local.name_prefix}-scp-deny-root"
      description = "Deny all root account API actions"
      content     = local.scp_deny_root
      type        = "SERVICE_CONTROL_POLICY"
    }
    restrict_regions = {
      name        = "${local.name_prefix}-scp-restrict-regions"
      description = "Restrict all API calls to us-east-1 and us-east-2"
      content     = local.scp_restrict_regions
      type        = "SERVICE_CONTROL_POLICY"
    }
    lock_cloudtrail = {
      name        = "${local.name_prefix}-scp-lock-cloudtrail"
      description = "Prevent disabling or modifying CloudTrail"
      content     = local.scp_lock_cloudtrail
      type        = "SERVICE_CONTROL_POLICY"
    }
    lock_config = {
      name        = "${local.name_prefix}-scp-lock-config"
      description = "Prevent disabling AWS Config recording"
      content     = local.scp_lock_config
      type        = "SERVICE_CONTROL_POLICY"
    }
    require_mfa = {
      name        = "${local.name_prefix}-scp-require-mfa"
      description = "Enforce MFA for all console access"
      content     = local.scp_require_mfa
      type        = "SERVICE_CONTROL_POLICY"
    }
    rcp_data_perimeter = {
      name        = "${local.name_prefix}-rcp-data-perimeter"
      description = "Enforce org-boundary data perimeter"
      content     = local.rcp_data_perimeter
      type        = "RESOURCE_CONTROL_POLICY"
    }
  }

  policy_attachments = {
    deny_root_root = {
      policy_key = "deny_root"
      target_id  = var.aws_org.root_id
    }
    restrict_regions_root = {
      policy_key = "restrict_regions"
      target_id  = var.aws_org.root_id
    }
    lock_cloudtrail_root = {
      policy_key = "lock_cloudtrail"
      target_id  = var.aws_org.root_id
    }
    lock_config_root = {
      policy_key = "lock_config"
      target_id  = var.aws_org.root_id
    }
    require_mfa_root = {
      policy_key = "require_mfa"
      target_id  = var.aws_org.root_id
    }
    rcp_data_perimeter_root = {
      policy_key = "rcp_data_perimeter"
      target_id  = var.aws_org.root_id
    }
  }

  sso_instance_arn           = var.sso.instance_arn
  permission_sets            = local.permission_sets
  managed_policy_attachments = local.managed_policy_attachments
  inline_policies            = {}

  common_tags = local.common_tags
}

module "security" {
  source = "../../modules/security"

  name_prefix                            = local.name_prefix
  region                                 = var.project.region_primary
  kms_key_rotation_enabled               = var.security.kms_key_rotation_enabled
  enable_secondary_kms                   = false
  guardduty_enabled                      = var.monitoring.guardduty_enabled
  guardduty_delegated_admin_account_id   = var.monitoring.guardduty_delegated_admin_account_id
  securityhub_fsbp_enabled               = var.monitoring.securityhub_enabled
  securityhub_nist_enabled               = var.logging.config_conformance_pack_nist
  securityhub_delegated_admin_account_id = var.monitoring.securityhub_delegated_admin_account_id

  common_tags = local.common_tags

  depends_on = [module.governance]
}

#===============================================================================
# CORE SOLUTION — Logging (DR region, replica bucket, full retention)
#===============================================================================
module "logging" {
  source = "../../modules/logging"

  name_prefix                    = local.name_prefix
  log_archive_bucket_name        = var.storage.log_archive_bucket_name_primary
  kms_key_arn                    = module.security.kms_key_arn_primary
  object_lock_enabled            = true
  object_lock_retention_days     = var.logging.cloudtrail_object_lock_retention_days
  glacier_transition_days        = var.storage.log_archive_glacier_transition_days
  trail_name                     = var.logging.cloudtrail_trail_name
  is_organization_trail          = true
  enable_cloudtrail_data_events  = false
  enable_cloudtrail_lake         = true
  cloudtrail_lake_retention_days = var.logging.cloudtrail_lake_retention_years * 365

  common_tags = local.common_tags

  depends_on = [module.security]
}

module "aft" {
  source = "../../modules/aft"

  aft_state_bucket_name      = var.storage.terraform_state_bucket_name
  aft_lock_table_name        = var.storage.terraform_state_dynamodb_lock_table
  kms_key_arn                = module.security.kms_key_arn_primary
  aft_terraform_version      = var.aft.pipeline_terraform_version
  aft_vending_sla_minutes    = var.aft.pipeline_vending_sla_minutes
  aft_codebuild_compute_type = var.aft.pipeline_codebuild_compute_type
  aft_max_concurrent_vending = var.aft.pipeline_max_concurrent_vending

  common_tags = local.common_tags

  depends_on = [module.security]
}

#===============================================================================
# OPERATIONS — Full monitoring (DR mirrors production)
#===============================================================================
module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix               = local.name_prefix
  kms_key_id                = module.security.kms_key_id_primary
  kms_key_arn               = module.security.kms_key_arn_primary
  log_retention_days        = var.monitoring.cloudwatch_log_retention_days
  dashboard_name_ops        = var.monitoring.cloudwatch_dashboard_name_ops
  dashboard_name_security   = var.monitoring.cloudwatch_dashboard_name_security
  dashboard_name_finops     = var.monitoring.cloudwatch_dashboard_name_finops
  guardduty_alert_threshold = var.monitoring.guardduty_alert_severity_threshold

  common_tags = local.common_tags

  depends_on = [module.security]
}

module "best_practices" {
  source = "../../modules/best-practices"

  name_prefix                    = local.name_prefix
  budgets_enabled                = true
  monthly_budget_usd             = var.finops.budgets_monthly_threshold_usd
  budget_alert_thresholds        = [var.aft.customisation_budget_alert_threshold_80, var.aft.customisation_budget_alert_threshold_100]
  budget_alert_emails            = []
  budget_sns_topic_arns          = [module.monitoring.sns_topic_arn_medium]
  cost_anomaly_detection_enabled = var.finops.cost_anomaly_detection_enabled
  anomaly_threshold_usd          = 500
  sns_topic_arn_medium           = module.monitoring.sns_topic_arn_medium

  common_tags = local.common_tags

  depends_on = [module.monitoring]
}

#===============================================================================
# INTEGRATIONS — Cross-module wiring
#===============================================================================
resource "aws_sns_topic_policy" "allow_eventbridge_critical" {
  arn    = module.monitoring.sns_topic_arn_critical
  policy = data.aws_iam_policy_document.sns_eventbridge_policy_critical.json
}

resource "aws_sns_topic_policy" "allow_eventbridge_high" {
  arn    = module.monitoring.sns_topic_arn_high
  policy = data.aws_iam_policy_document.sns_eventbridge_policy_high.json
}

data "aws_iam_policy_document" "sns_eventbridge_policy_critical" {
  statement {
    sid    = "AllowEventBridgePublish"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions   = ["SNS:Publish"]
    resources = [module.monitoring.sns_topic_arn_critical]
  }
}

data "aws_iam_policy_document" "sns_eventbridge_policy_high" {
  statement {
    sid    = "AllowEventBridgePublish"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions   = ["SNS:Publish"]
    resources = [module.monitoring.sns_topic_arn_high]
  }
}
