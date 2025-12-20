# ============================================================================
# Azure FinOps Storage Lifecycle Module - Outputs
# ============================================================================

output "policy_id" {
  description = "The ID of the Storage Management Policy."
  value       = azurerm_storage_management_policy.lifecycle.id
}

output "storage_account_id" {
  description = "The ID of the Storage Account the policy is applied to."
  value       = local.storage_account_id
}
