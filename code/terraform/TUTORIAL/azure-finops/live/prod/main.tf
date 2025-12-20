provider "azurerm" {
  features {}
}

# --- PRODUCTION ENVIRONMENT ---
# In Prod, we DENY deployments without tags.
# We have strict budgets.
# We rely on aggressive storage lifecycle management.

module "tagging_enforce" {
  source          = "../../modules/finops-tagging-policy"
  subscription_id = var.subscription_id
  policy_effect   = "Deny"
}

module "prod_budget" {
  source              = "../../modules/finops-budget-guardrails"
  resource_group_name = "rg-prod-app"
  resource_group_id   = "/subscriptions/.../resourceGroups/rg-prod-app"
  budget_amount       = 5000
  alert_email_address = "finops-alerts@company.com"
}

module "cost_export" {
  source               = "../../modules/finops-cost-export"
  resource_group_name  = "rg-prod-finops"
  location             = "eastus"
  storage_account_name = "stprodcostexport01"
}

module "prod_lifecycle" {
  source             = "../../modules/finops-storage-lifecycle"
  storage_account_id = "/subscriptions/.../storageAccounts/stproddata"
}
