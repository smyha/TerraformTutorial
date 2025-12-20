provider "azurerm" {
  features {}
}

# --- 1. Optimization: Deep Storage Lifecycle ---
# Aggressively tier old logs to Archive.
module "log_tiering" {
  source             = "../../modules/finops-storage-lifecycle"
  storage_account_id = "/subscriptions/.../storageAccounts/stlogs001"
  container_prefixes = ["app-logs", "audit-logs"]
}

# --- 2. Specialized: Kubernetes Cost Allocation ---
# Gain visibility into shared cluster costs.
module "aks_cost_agent" {
  source         = "../../modules/k8s-cost-agent"
  aks_cluster_id = "/subscriptions/.../managedClusters/aks-shared-01"
}

# Note: In this phase, you would also automate the deletion of resources found by the
# 'finops-orphan-cleanup' module using Logic Apps or Azure Functions triggering off the queries.
