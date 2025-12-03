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

terragrunt_version_constraint = ">= 0.50.0"

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
#   4. All state files are stored in the same Azure Storage Account but with different keys
#
# BENEFITS:
#   - DRY: Define backend config once, reuse everywhere
#   - Consistent: All modules use the same backend settings
#   - Automatic: No need to manually write backend.tf in each module
# ============================================================================
remote_state {
  backend = "azurerm"

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
  # BACKEND CONFIG: Azure Storage Backend Settings
  # ========================================================================
  # These settings are used to generate the backend.tf file. Each module
  # will get a unique state key based on its path relative to this file.
  #
  # KEY FUNCTIONS:
  #   - get_env("VAR", "default"): Reads environment variable, uses default if not set
  #   - path_relative_to_include(): Returns path like "networking/vnet"
  #     This creates unique state keys: "stage/networking/vnet/terraform.tfstate"
  #
  # ENVIRONMENT VARIABLES REQUIRED:
  #   - TF_STATE_STORAGE_ACCOUNT_NAME: Azure Storage Account name for state
  #   - TF_STATE_RESOURCE_GROUP_NAME: Resource group containing the storage account
  #   - TF_STATE_CONTAINER_NAME: Storage container name (e.g., "terraform-state")
  #   - TF_STATE_KEY: Optional prefix for state keys (defaults to "stage")
  # ========================================================================
  config = {
    # Azure Storage Account where all state files are stored
    # Set via: export TF_STATE_STORAGE_ACCOUNT_NAME=myterraformstate
    storage_account_name = get_env("TF_STATE_STORAGE_ACCOUNT_NAME", "")

    # Resource group containing the storage account
    # Set via: export TF_STATE_RESOURCE_GROUP_NAME=rg-terraform-state
    resource_group_name = get_env("TF_STATE_RESOURCE_GROUP_NAME", "")

    # Storage container name for state files
    # Set via: export TF_STATE_CONTAINER_NAME=terraform-state
    container_name = get_env("TF_STATE_CONTAINER_NAME", "terraform-state")

    # Unique key per module based on its path
    # Example: "stage/networking/vnet/terraform.tfstate"
    # This ensures each module has its own state file
    key = "${get_env("TF_STATE_KEY", "stage")}/${path_relative_to_include()}/terraform.tfstate"

    # Enable encryption at rest for state files
    # Azure Storage automatically encrypts data at rest
    # This is just for documentation - encryption is always enabled in Azure Storage
  }
}

# ============================================================================
# GLOBAL INPUTS (Optional)
# ============================================================================
# These inputs are available to all child modules. They can be overridden
# in individual terragrunt.hcl files if needed.
#
# Common use cases:
#   - Environment name
#   - Default tags
#   - Shared resource group names
#   - Default location/region
# ============================================================================
inputs = {
  # Environment identifier
  environment = "stage"

  # Default Azure region for resources
  # Can be overridden per module if needed
  location = get_env("TF_VAR_location", "eastus")

  # Default tags applied to all resources
  # Individual modules can add additional tags
  common_tags = {
    Environment = "stage"
    ManagedBy   = "Terragrunt"
    Project     = "Azure-Networking-Tutorial"
  }
}

