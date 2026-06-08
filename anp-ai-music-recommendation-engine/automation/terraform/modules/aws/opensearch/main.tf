#------------------------------------------------------------------------------
# Tier 1 — AWS OpenSearch Service: Single-node domain for semantic catalog search
#------------------------------------------------------------------------------

resource "aws_security_group" "opensearch" {
  name        = "${var.name_prefix}-opensearch-sg"
  description = "Security group for OpenSearch domain - allows inbound from application tier only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTPS from application security group"
    from_port       = 443
    to_port         = 443
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
    Name = "${var.name_prefix}-opensearch-sg"
  })
}

resource "aws_opensearch_domain" "main" {
  domain_name    = "${var.name_prefix}-catalog"
  engine_version = "OpenSearch_2.11"

  cluster_config {
    instance_type  = var.instance_type
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.volume_gb
    volume_type = "gp3"
  }

  vpc_options {
    subnet_ids         = [var.subnet_id]
    security_group_ids = [aws_security_group.opensearch.id]
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.catalog_kms_key_arn
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled                        = true
    anonymous_auth_enabled         = false
    internal_user_database_enabled = false

    master_user_options {
      master_user_arn = data.aws_caller_identity.current.arn
    }
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-opensearch"
  })
}

resource "aws_cloudwatch_log_group" "opensearch" {
  name              = "/aws/opensearch/${var.name_prefix}-catalog"
  retention_in_days = 30

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-opensearch-logs"
  })
}

resource "aws_cloudwatch_log_resource_policy" "opensearch" {
  policy_name = "${var.name_prefix}-opensearch-log-policy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
        ]
        Resource = "arn:aws:logs:*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
