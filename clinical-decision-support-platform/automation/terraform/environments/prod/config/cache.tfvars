#------------------------------------------------------------------------------
# Cache Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-30 01:10:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

cache = {
  # Enable encryption at rest for ElastiCache Redis using dedicated KMS CMK
  elasticache_at_rest_encryption = true
  # ElastiCache Redis cluster identifier for patient context and feature vector caching
  elasticache_cluster_id = "medcore-cds-prod-redis"
  # TTL in seconds for alert duplicate suppression window in Redis (30 minutes per alert type)
  elasticache_duplicate_suppression_ttl_seconds = 1800
  # Enable Multi-AZ replication with automatic failover for ElastiCache Redis
  elasticache_multi_az_enabled = true
  elasticache_node_type = "cache.r7g.large"  # ElastiCache Redis node instance type
  # TTL in seconds for patient feature vector entries in Redis (4 hours = maximum clinical review window)
  elasticache_ttl_patient_context_seconds = 14400
}
