# ============================================================================
# Azure FinOps Orphan Cleanup Module - Outputs
# ============================================================================

output "orphaned_disks_query_id" {
  description = "The ID of the orphaned disks query (if created)."
  value       = var.create_orphaned_disks_query ? azurerm_resource_graph_query.orphaned_disks[0].id : null
}

output "orphaned_disks_query_name" {
  description = "The name of the orphaned disks query."
  value       = var.create_orphaned_disks_query ? azurerm_resource_graph_query.orphaned_disks[0].name : null
}

output "orphaned_public_ips_query_id" {
  description = "The ID of the orphaned public IPs query (if created)."
  value       = var.create_orphaned_public_ips_query ? azurerm_resource_graph_query.orphaned_public_ips[0].id : null
}

output "orphaned_public_ips_query_name" {
  description = "The name of the orphaned public IPs query."
  value       = var.create_orphaned_public_ips_query ? azurerm_resource_graph_query.orphaned_public_ips[0].name : null
}

output "orphaned_nics_query_id" {
  description = "The ID of the orphaned NICs query (if created)."
  value       = var.create_orphaned_nics_query ? azurerm_resource_graph_query.orphaned_nics[0].id : null
}

output "orphaned_nics_query_name" {
  description = "The name of the orphaned NICs query."
  value       = var.create_orphaned_nics_query ? azurerm_resource_graph_query.orphaned_nics[0].name : null
}

output "orphaned_storage_accounts_query_id" {
  description = "The ID of the orphaned storage accounts query (if created)."
  value       = var.create_orphaned_storage_accounts_query ? azurerm_resource_graph_query.orphaned_storage_accounts[0].id : null
}

output "orphaned_storage_accounts_query_name" {
  description = "The name of the orphaned storage accounts query."
  value       = var.create_orphaned_storage_accounts_query ? azurerm_resource_graph_query.orphaned_storage_accounts[0].name : null
}
