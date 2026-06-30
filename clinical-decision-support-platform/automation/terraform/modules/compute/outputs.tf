output "alb_dashboard_arn" {
  description = "Dashboard ALB ARN"
  value       = module.alb_dashboard.alb_arn
}

output "alb_dashboard_dns_name" {
  description = "Dashboard ALB DNS name"
  value       = module.alb_dashboard.alb_dns_name
}

output "alb_dashboard_security_group_id" {
  description = "Dashboard ALB security group ID"
  value       = module.alb_dashboard.security_group_id
}

output "alb_fhir_arn" {
  description = "FHIR inbound ALB ARN"
  value       = module.alb_fhir.alb_arn
}

output "alb_fhir_dns_name" {
  description = "FHIR inbound ALB DNS name"
  value       = module.alb_fhir.alb_dns_name
}

output "alb_fhir_security_group_id" {
  description = "FHIR ALB security group ID"
  value       = module.alb_fhir.security_group_id
}

output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = module.ecs_dashboard.cluster_id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_dashboard.cluster_name
}

output "ecs_dashboard_service_name" {
  description = "ECS dashboard service name"
  value       = module.ecs_dashboard.service_name
}

output "ecs_dashboard_security_group_id" {
  description = "ECS dashboard tasks security group ID"
  value       = module.ecs_dashboard.security_group_id
}

output "ecs_api_security_group_id" {
  description = "ECS API tasks security group ID"
  value       = module.ecs_api.security_group_id
}

output "dashboard_waf_web_acl_arn" {
  description = "Dashboard ALB HTTPS listener ARN (for WAF association)"
  value       = module.alb_dashboard.https_listener_arn
}
