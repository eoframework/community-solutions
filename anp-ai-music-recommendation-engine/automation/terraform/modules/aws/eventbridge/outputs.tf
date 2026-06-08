output "event_bus_arn" {
  description = "EventBridge custom event bus ARN"
  value       = aws_cloudwatch_event_bus.main.arn
}

output "event_bus_name" {
  description = "EventBridge custom event bus name"
  value       = aws_cloudwatch_event_bus.main.name
}
