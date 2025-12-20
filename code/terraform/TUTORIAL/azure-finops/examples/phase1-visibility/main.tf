provider "azurerm" {
  features {}
}

# --- 1. Foundation: Tagging (Audit Mode) ---
# Identify resources missing Owner or CostCenter tags, but don't block them yet.
module "tagging_policy" {
  source          = "../../modules/finops-tagging-policy"
  subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  policy_effect   = "Audit"
}

# --- 2. Governance: Global Budget Guardrail ---
# Set a high-level budget for the critical Production Resource Group.
module "prod_budget" {
  source              = "../../modules/finops-budget-guardrails"
  resource_group_name = "rg-production"
  resource_group_id   = "/subscriptions/.../resourceGroups/rg-production"
  budget_amount       = 5000
  alert_email_address = "finops@company.com"
}

# --- 3. Observability: Cost Export ---
# Start collecting granular data to a storage account.
module "cost_export" {
  source               = "../../modules/finops-cost-export"
  resource_group_name  = "rg-finops-data"
  resource_group_id    = "/subscriptions/.../resourceGroups/rg-finops-data"
  location             = "eastus"
  storage_account_name = "stfinopsexport001"
}
