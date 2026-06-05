output "detector_id" {
  description = "GuardDuty detector ID"
  value       = var.enabled ? aws_guardduty_detector.main[0].id : ""
}
