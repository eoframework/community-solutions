#------------------------------------------------------------------------------
# Cache Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-08 21:29:43
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

cache = {
  # Enable ElastiCache playlist and session caching layer
  enabled = true
  # ElastiCache Redis cluster primary endpoint hostname
  host = "[elasticache-endpoint]"  # TODO: Replace with actual value
  # ElastiCache TTL in seconds for cached generated playlists
  playlist_ttl_seconds = 600
  # Redis port for ElastiCache cluster connections
  port = 6379
  # ElastiCache TTL in seconds for cached session context objects
  session_ttl_seconds = 1800
}
