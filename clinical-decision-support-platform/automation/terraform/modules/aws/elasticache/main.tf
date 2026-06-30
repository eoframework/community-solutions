################################################################################
# Tier 1 — AWS ElastiCache Redis Module
################################################################################

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name_prefix}-redis-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-redis-subnet-group"
  })
}

resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-redis-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
    description     = "Redis from application tier"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-redis-sg"
  })
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.cluster_id
  description          = "ElastiCache Redis for ${var.name_prefix} patient context and feature caching"

  node_type            = var.node_type
  num_cache_clusters   = var.multi_az_enabled ? 2 : 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [aws_security_group.redis.id]

  at_rest_encryption_enabled  = true
  transit_encryption_enabled  = true
  transit_encryption_mode     = "required"
  kms_key_id                  = var.kms_key_arn
  automatic_failover_enabled  = var.multi_az_enabled
  multi_az_enabled            = var.multi_az_enabled

  snapshot_retention_limit = var.snapshot_retention_days
  snapshot_window          = "03:00-04:00"
  maintenance_window       = "sun:05:00-sun:06:00"
  auto_minor_version_upgrade = true

  log_delivery_configuration {
    destination      = "/aws/elasticache/${var.name_prefix}-redis/slow-logs"
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  tags = merge(var.common_tags, {
    Name = var.cluster_id
  })
}
