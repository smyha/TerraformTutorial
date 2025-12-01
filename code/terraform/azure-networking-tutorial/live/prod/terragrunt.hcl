# ============================================================================
# TERRAGRUNT ROOT CONFIGURATION (Production Environment)
# ============================================================================
# This is the root terragrunt.hcl file for the production environment.
# It follows the same structure as stage but with production-specific settings.
# ============================================================================

terragrunt_version_constraint = ">= 0.50.0"

remote_state {
  backend = "azurerm"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    storage_account_name = get_env("TF_STATE_STORAGE_ACCOUNT_NAME", "")
    resource_group_name  = get_env("TF_STATE_RESOURCE_GROUP_NAME", "")
    container_name       = get_env("TF_STATE_CONTAINER_NAME", "terraform-state")
    
    # Production state files use "prod" prefix
    key = "prod/${path_relative_to_include()}/terraform.tfstate"
  }
}

inputs = {
  environment = "prod"
  location    = get_env("TF_VAR_location", "eastus")

  common_tags = {
    Environment = "production"
    ManagedBy   = "Terragrunt"
    Project     = "Azure-Networking-Tutorial"
  }
}

