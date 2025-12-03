# ============================================================================
# TERRAGRUNT CONFIGURATION: MySQL Database (Production Environment)
# ============================================================================
# Production MySQL RDS database configuration. This is a critical dependency
# for the hello-world-app service in production.
#
# PRODUCTION DIFFERENCES FROM STAGING:
#   - db_name: "example_prod" (vs "example_stage")
#   - Uses production backend bucket (inherited from parent)
#   - Should use stronger credentials (via environment variables)
#   - May have different backup/retention policies
# ============================================================================

terraform {
  source = "../../../../modules//data-stores/mysql"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  # Production database name
  db_name = "example_prod"

  # CRITICAL: Never hardcode credentials in production!
  # Always use environment variables:
  #   export TF_VAR_db_username=admin
  #   export TF_VAR_db_password=<strong-password>
  #
  # Or use a secrets manager (AWS Secrets Manager, HashiCorp Vault, etc.)
  # Set the username using the TF_VAR_db_username environment variable
  # Set the password using the TF_VAR_db_password environment variable
}
