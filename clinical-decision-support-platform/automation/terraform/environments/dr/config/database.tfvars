#------------------------------------------------------------------------------
# Database Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-30 01:10:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  # Automated snapshot retention period in days for Aurora PostgreSQL
  aurora_backup_retention_days = 35
  # RDS Aurora PostgreSQL cluster identifier for risk scores and alert history
  aurora_cluster_identifier = "medcore-cds-prod-aurora-cluster"
  # Database name within the Aurora PostgreSQL cluster
  aurora_db_name = "medcore_cds"
  # Enable deletion protection on Aurora cluster to prevent accidental drops
  aurora_deletion_protection = true
  # RDS Aurora PostgreSQL instance class for primary and replica nodes
  aurora_instance_type = "db.r6g.large"
  # SECRET (Aurora PostgreSQL master password stored in Secrets Manager; never committed to IaC or code): inject via Secrets Manager / SSM at deploy time
  aurora_master_password = "SET_VIA_SECRETS_MANAGER"
  # SECRET (Aurora PostgreSQL master username stored in Secrets Manager; never in plaintext): inject via Secrets Manager / SSM at deploy time
  aurora_master_username = "SET_VIA_SECRETS_MANAGER"
  # Enable Multi-AZ replication for Aurora PostgreSQL primary instance
  aurora_multi_az_enabled = true
  # SSL enforcement mode for Aurora PostgreSQL client connections
  aurora_ssl_mode = "require"
}
