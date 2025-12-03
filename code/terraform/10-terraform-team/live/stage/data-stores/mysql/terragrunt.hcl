# ============================================================================
# TERRAGRUNT CONFIGURATION: MySQL Database (Stage Environment)
# ============================================================================
# This file configures the MySQL RDS database for the stage environment.
# It's a dependency for the hello-world-app service, which will automatically
# wait for this to be deployed before deploying itself.
# ============================================================================

# ============================================================================
# TERRAFORM SOURCE
# ============================================================================
# Points to the reusable MySQL module. The double slash (//) ensures Terragrunt
# uses the exact path specified, not a relative path calculation.
# ============================================================================
terraform {
  source = "../../../../modules//data-stores/mysql"
}

# ============================================================================
# INCLUDE BLOCK: Inherit Parent Configuration
# ============================================================================
# Inherits the remote_state configuration from live/stage/terragrunt.hcl.
# This means this module will automatically:
#   - Use the same S3 bucket for state
#   - Get a unique state key: "data-stores/mysql/terraform.tfstate"
#   - Use the same DynamoDB table for locking
# ============================================================================
include {
  path = find_in_parent_folders()
}

# ============================================================================
# INPUTS: Module Variables
# ============================================================================
# These inputs configure the MySQL database. Sensitive values (username/password)
# should be passed via environment variables to avoid storing them in code.
#
# ENVIRONMENT VARIABLES:
#   - TF_VAR_db_username: Database admin username
#   - TF_VAR_db_password: Database admin password
#
# These are read by Terraform automatically when prefixed with TF_VAR_
# ============================================================================
inputs = {
  db_name = "example_stage"

  # Set the username using the TF_VAR_db_username environment variable
  # Set the password using the TF_VAR_db_password environment variable
  # Example: export TF_VAR_db_username=admin && export TF_VAR_db_password=secret
}
