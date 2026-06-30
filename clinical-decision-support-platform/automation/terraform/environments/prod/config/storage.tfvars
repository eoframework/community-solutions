#------------------------------------------------------------------------------
# Storage Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-30 01:10:29
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  # Expected active FHIR store storage in TB at full 18-hospital utilization
  healthlake_active_storage_tb = "1"
  # Amazon HealthLake FHIR R4 datastore ID for PHI persistence and longitudinal patient records
  healthlake_datastore_id = "[healthlake-datastore-id]"  # TODO: Replace with actual value
  # FHIR version for Amazon HealthLake datastore configuration
  healthlake_fhir_version = "R4"
  # Minimum retention period in years for HealthLake FHIR patient data
  healthlake_retention_years = 7
  # Amazon Redshift cluster identifier for longitudinal outcomes warehouse
  redshift_cluster_identifier = "medcore-cds-prod-redshift"
  # Amazon Redshift node type for the outcomes analytics warehouse
  redshift_node_type = "ra3.xlplus"
  # Automated snapshot retention in days for Redshift cluster
  redshift_snapshot_retention_days = 7
  # S3 bucket name for CloudTrail PHI audit log delivery
  s3_audit_bucket_name = "[s3-audit-bucket-name]"  # TODO: Replace with actual value
  # Enable S3 cross-region replication from us-east-1 to us-west-2 for all data lake buckets
  s3_cross_region_replication_enabled = true
  # S3 bucket name for PHI data lake (HL7 event archives and ML model artefacts)
  s3_datalake_bucket_name = "[s3-datalake-bucket-name]"  # TODO: Replace with actual value
  # S3 bucket name for SageMaker model artefacts and training job outputs
  s3_model_artefacts_bucket_name = "[s3-model-artefacts-bucket-name]"  # TODO: Replace with actual value
  # S3 Object Lock compliance retention period in years for the audit log bucket
  s3_object_lock_retention_years = 7
}
