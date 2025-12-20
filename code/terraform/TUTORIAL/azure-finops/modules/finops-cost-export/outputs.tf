# ============================================================================
# Azure FinOps Cost Export Module - Outputs
# ============================================================================

output "storage_account_id" {
  description = "The ID of the Storage Account storing the exports (created or existing)."
  value       = local.storage_account_id
}

output "storage_account_name" {
  description = "The name of the Storage Account storing the exports."
  value       = local.storage_account_name
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint of the Storage Account."
  value       = var.create_storage_account ? azurerm_storage_account.export[0].primary_blob_endpoint : null
}

output "container_id" {
  description = "The ID of the storage container for cost exports."
  value       = azurerm_storage_container.export.id
}

output "container_name" {
  description = "The name of the storage container for cost exports."
  value       = azurerm_storage_container.export.name
}

output "export_id" {
  description = "The ID of the Cost Management Export configuration."
  value       = azurerm_cost_management_export_resource_group.export.id
}

output "export_name" {
  description = "The name of the Cost Management Export configuration."
  value       = azurerm_cost_management_export_resource_group.export.name
}

output "export_storage_path" {
  description = "The full storage path where cost exports are stored (for reference in Power BI, etc.)."
  value       = "${local.storage_account_name}/${azurerm_storage_container.export.name}/${var.root_folder_path}"
}
