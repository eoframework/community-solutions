#------------------------------------------------------------------------------
# AWS GuardDuty Tier-1 Module
# Enables GuardDuty with organisation-wide configuration
#------------------------------------------------------------------------------

resource "aws_guardduty_detector" "this" {
  enable = var.enabled
  tags   = merge(var.common_tags, { Name = var.detector_name })

  datasources {
    s3_logs {
      enable = var.enable_s3_logs
    }
    kubernetes {
      audit_logs {
        enable = var.enable_kubernetes_logs
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.enable_malware_protection
        }
      }
    }
  }
}

resource "aws_guardduty_organization_admin_account" "this" {
  count            = var.delegated_admin_account_id != null ? 1 : 0
  admin_account_id = var.delegated_admin_account_id
  depends_on       = [aws_guardduty_detector.this]
}
