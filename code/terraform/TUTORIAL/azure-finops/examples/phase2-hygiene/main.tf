provider "azurerm" {
  features {}
}

# --- 1. Foundation: Tagging (Deny Mode) ---
# Now enforcing tags. Deployment fails if tags are missing.
module "tagging_policy" {
  source          = "../../modules/finops-tagging-policy"
  subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  policy_effect   = "Deny"
}

# --- 2. Optimization: Resource Scheduler ---
# Stop Dev VMs automatically at 7 PM.
module "dev_scheduler" {
  source                  = "../../modules/finops-resource-scheduler"
  resource_group_name     = "rg-dev-environment"
  location                = "eastus"
  automation_account_name = "aa-dev-scheduler"
}

# --- 3. Optimization: Orphan Cleanup (Reporting) ---
# Identify waste. In this phase, we just query/report.
module "orphan_finder" {
  source            = "../../modules/finops-orphan-cleanup"
  resource_group_id = "/subscriptions/.../resourceGroups/rg-finops-tools"
}
