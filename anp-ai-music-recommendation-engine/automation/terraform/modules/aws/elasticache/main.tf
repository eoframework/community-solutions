#------------------------------------------------------------------------------
# Tier 1 — AWS ElastiCache: Redis replication group with encryption
#------------------------------------------------------------------------------

resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-redis-sg"
  description = "Security group for ElastiCache Redis - allows inbound from application tier only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from application security group"
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-redis-sg"
  })
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name_prefix}-redis-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-redis-subnet-group"
  })
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.name_prefix}-redis"
  description          = "Redis cluster for playlist and session caching"
  node_type            = var.node_type
  num_cache_clusters   = 1
  port                 = var.port

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                 = var.kms_key_arn

  automatic_failover_enabled = false
  multi_az_enabled           = false

  engine               = "redis"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"

  apply_immediately = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-redis"
  })
}
