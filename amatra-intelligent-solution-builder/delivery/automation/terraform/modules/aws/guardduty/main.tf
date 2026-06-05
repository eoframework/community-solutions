#------------------------------------------------------------------------------
# Tier 1: AWS GuardDuty — Threat detection per SOC 2 baseline
#------------------------------------------------------------------------------

resource "aws_guardduty_detector" "main" {
  count  = var.enabled ? 1 : 0
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
          enable = false
        }
      }
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-guardduty"
  })
}
