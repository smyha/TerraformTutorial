provider "azurerm" {
  features {}
}

# --- STAGING ENVIRONMENT ---
# In Stage, we audit tags but don't deny deployment.
# We run budgets to test alerting flow.
# We test auto-shutdown on all VMs.

module "tagging_audit" {
  source          = "../../modules/finops-tagging-policy"
  subscription_id = var.subscription_id
  policy_effect   = "Audit"
}

module "dev_budget" {
  source              = "../../modules/finops-budget-guardrails"
  resource_group_name = "rg-stage-app"
  resource_group_id   = "/subscriptions/.../resourceGroups/rg-stage-app"
  budget_amount       = 200
  alert_email_address = "dev-team@company.com"
}

module "auto_shutdown" {
  source                  = "../../modules/finops-resource-scheduler"
  resource_group_name     = "rg-stage-app"
  location                = "eastus"
  automation_account_name = "aa-stage-shutdown"
}
