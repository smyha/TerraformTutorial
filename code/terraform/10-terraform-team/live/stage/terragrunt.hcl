# ============================================================================
# TERRAGRUNT ROOT CONFIGURATION (Stage Environment)
# ============================================================================
# This is the root terragrunt.hcl file for the stage environment. It defines
# shared configuration that all child Terragrunt configurations will inherit
# through the `include` block.
#
# KEY CONCEPTS:
#   - This file is included by all child terragrunt.hcl files via:
#     include { path = find_in_parent_folders() }
#   - remote_state: Configures the backend for all Terraform state files
#   - generate: Automatically creates backend.tf files in each module directory
#   - path_relative_to_include(): Creates unique state keys per module
# ============================================================================

terragrunt_version_constraint = ">= v0.36.0"

# ============================================================================
# REMOTE STATE CONFIGURATION
# ============================================================================
# This block configures where Terraform state files are stored. Terragrunt
# will automatically generate a backend.tf file in each module directory
# with these settings.
#
# HOW IT WORKS:
#   1. Terragrunt reads this remote_state block
#   2. Uses the `generate` block to create backend.tf in each module
#   3. Each module gets a unique state key based on its path
#   4. All state files are stored in the same S3 bucket but with different keys
#
# BENEFITS:
#   - DRY: Define backend config once, reuse everywhere
#   - Consistent: All modules use the same backend settings
#   - Automatic: No need to manually write backend.tf in each module
# ============================================================================
remote_state {
  backend = "s3"

  # ========================================================================
  # GENERATE BLOCK: Auto-generate backend.tf files
  # ========================================================================
  # This tells Terragrunt to automatically create a backend.tf file in each
  # module directory with the backend configuration.
  #
  # Options:
  #   - path: Name of the file to generate (typically "backend.tf")
  #   - if_exists: What to do if the file already exists
  #     * "overwrite": Replace existing file (recommended)
  #     * "skip": Keep existing file
  #     * "error": Fail if file exists
  # ========================================================================
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  # ========================================================================
  # BACKEND CONFIG: S3 Backend Settings
  # ========================================================================
  # These settings are used to generate the backend.tf file. Each module
  # will get a unique state key based on its path relative to this file.
  #
  # KEY FUNCTIONS:
  #   - get_env("VAR", "default"): Reads environment variable, uses default if not set
  #   - path_relative_to_include(): Returns path like "services/hello-world-app"
  #     This creates unique state keys: "services/hello-world-app/terraform.tfstate"
  # ========================================================================
  config = {
    # S3 bucket where all state files are stored
    # Set via: export TEST_STATE_S3_BUCKET=my-terraform-state-bucket
    bucket = get_env("TEST_STATE_S3_BUCKET", "")

    # Unique key per module based on its path
    # Example: "services/hello-world-app/terraform.tfstate"
    # This ensures each module has its own state file
    key = "${path_relative_to_include()}/terraform.tfstate"

    # AWS region for the S3 bucket
    # Set via: export TEST_STATE_REGION=us-east-2
    region = get_env("TEST_STATE_REGION", "")

    # Enable encryption at rest for state files
    encrypt = true

    # DynamoDB table for state locking (prevents concurrent modifications)
    # Set via: export TEST_STATE_DYNAMODB_TABLE=terraform-state-lock
    dynamodb_table = get_env("TEST_STATE_DYNAMODB_TABLE", "")
  }
}
