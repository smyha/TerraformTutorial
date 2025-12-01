# ============================================================================
# Basic Virtual Network Example - Outputs
# ============================================================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = module.vnet.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.vnet.subnet_ids
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes"
  value       = module.vnet.subnet_address_prefixes
}

output "network_security_group_ids" {
  description = "Map of NSG names to their IDs"
  value       = module.vnet.network_security_group_ids
}

