# ============================================================================
# TERRAGRUNT ROOT CONFIGURATION (Production Environment)
# ============================================================================
# This is the root terragrunt.hcl file for the production environment.
# It defines shared configuration that all child Terragrunt configurations
# will inherit through the `include` block.
#
# PRODUCTION CONSIDERATIONS:
#   - Should use a separate S3 bucket from staging for isolation
#   - Should use separate DynamoDB table for state locking
#   - May have stricter access controls
#   - Should use environment variables for all sensitive values
# ============================================================================

terragrunt_version_constraint = ">= v0.36.0"

# ============================================================================
# REMOTE STATE CONFIGURATION (Production)
# ============================================================================
# Production backend configuration. In a real-world scenario, you would
# typically use different bucket/table names for production vs staging
# to ensure complete isolation between environments.
#
# SECURITY BEST PRACTICES:
#   - Use separate AWS accounts or at minimum separate buckets for prod
#   - Enable versioning on the S3 bucket
#   - Use KMS encryption keys for state files
#   - Restrict IAM permissions to production state bucket
# ============================================================================
remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    # Production state bucket (should be different from staging)
    bucket = get_env("TEST_STATE_S3_BUCKET", "")

    # Unique key per module: "prod/data-stores/mysql/terraform.tfstate"
    key = "${path_relative_to_include()}/terraform.tfstate"

    region = get_env("TEST_STATE_REGION", "")

    # Always encrypt production state files
    encrypt = true

    # Production state locking table
    dynamodb_table = get_env("TEST_STATE_DYNAMODB_TABLE", "")
  }
}
