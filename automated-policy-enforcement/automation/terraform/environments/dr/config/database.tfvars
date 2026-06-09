#------------------------------------------------------------------------------
# Database Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2026-06-09 21:41:31
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  # Enable DynamoDB point-in-time recovery on AFT workflow state table
  aft_workflow_backup_enabled = true
  # DynamoDB billing mode for AFT workflow state table
  aft_workflow_billing_mode = "PAY_PER_REQUEST"
  # DynamoDB table name storing AFT account vending workflow state
  aft_workflow_table_name = "cntso-aft-workflow-dr"
  # DynamoDB table name for Terraform state locking across all workspaces
  terraform_state_lock_table = "cntso-tf-state-lock-dr"
}
