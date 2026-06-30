################################################################################
# Tier 2 — Compute Module
# Composes aws/alb + aws/ecs for clinical dashboard and API backend.
################################################################################

# ---------------------------------------------------------------------------
# ALBs — clinical dashboard + FHIR inbound
# ---------------------------------------------------------------------------
module "alb_dashboard" {
  source = "../aws/alb"

  name_prefix                = var.name_prefix
  alb_name_suffix            = "dashboard"
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.public_subnet_ids
  certificate_arn            = var.certificate_arn
  target_port                = var.compute.app_port
  health_check_path          = "/api/v1/health"
  internal                   = false
  enable_deletion_protection = var.compute.enable_deletion_protection

  common_tags = var.common_tags
}

module "alb_fhir" {
  source = "../aws/alb"

  name_prefix                = var.name_prefix
  alb_name_suffix            = "fhir-inbound"
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.public_subnet_ids
  certificate_arn            = var.certificate_arn
  target_port                = var.compute.app_port
  health_check_path          = "/api/v1/health"
  internal                   = false
  enable_deletion_protection = var.compute.enable_deletion_protection

  common_tags = var.common_tags
}

# ---------------------------------------------------------------------------
# ECS Fargate — clinical dashboard service
# ---------------------------------------------------------------------------
module "ecs_dashboard" {
  source = "../aws/ecs"

  name_prefix            = var.name_prefix
  cluster_name           = var.compute.ecs_cluster_name
  service_name           = "dashboard"
  environment            = var.environment
  aws_region             = var.aws_region
  vpc_id                 = var.vpc_id
  subnet_ids             = var.app_subnet_ids
  alb_security_group_ids = [module.alb_dashboard.security_group_id]
  target_group_arn       = module.alb_dashboard.target_group_arn
  container_image        = var.compute.dashboard_container_image
  container_port         = var.compute.app_port
  task_cpu               = var.compute.ecs_task_cpu
  task_memory_mb         = var.compute.ecs_task_memory_mb
  min_capacity           = var.compute.ecs_scaling_min
  max_capacity           = var.compute.ecs_scaling_max
  kms_key_arn            = var.kms_key_arn
  log_retention_days     = var.compute.log_retention_days
  secrets_arns           = var.secrets_arns

  environment_variables = [
    { name = "APP_ENV", value = var.environment },
    { name = "LOG_LEVEL", value = var.compute.log_level },
    { name = "APP_PORT", value = tostring(var.compute.app_port) }
  ]

  common_tags = var.common_tags
}

# ---------------------------------------------------------------------------
# ECS Fargate — API backend service (separate from dashboard frontend)
# ---------------------------------------------------------------------------
module "ecs_api" {
  source = "../aws/ecs"

  name_prefix            = var.name_prefix
  cluster_name           = var.compute.ecs_cluster_name
  service_name           = "api-backend"
  environment            = var.environment
  aws_region             = var.aws_region
  vpc_id                 = var.vpc_id
  subnet_ids             = var.app_subnet_ids
  alb_security_group_ids = [module.alb_dashboard.security_group_id]
  target_group_arn       = null
  container_image        = var.compute.api_container_image
  container_port         = var.compute.app_port
  task_cpu               = var.compute.ecs_task_cpu
  task_memory_mb         = var.compute.ecs_task_memory_mb
  min_capacity           = var.compute.ecs_scaling_min
  max_capacity           = var.compute.ecs_scaling_max
  kms_key_arn            = var.kms_key_arn
  log_retention_days     = var.compute.log_retention_days
  secrets_arns           = var.secrets_arns

  environment_variables = [
    { name = "APP_ENV", value = var.environment },
    { name = "LOG_LEVEL", value = var.compute.log_level }
  ]

  common_tags = var.common_tags
}
