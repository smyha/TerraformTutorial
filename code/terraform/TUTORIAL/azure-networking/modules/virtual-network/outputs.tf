# ============================================================================
# Azure Virtual Network Module - Outputs
# ============================================================================

output "virtual_network_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "virtual_network_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "virtual_network_address_space" {
  description = "The address space of the Virtual Network"
  value       = azurerm_virtual_network.main.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value = {
    for k, v in azurerm_subnet.main : k => v.id
  }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes"
  value = {
    for k, v in azurerm_subnet.main : k => v.address_prefixes
  }
}

output "subnet_names" {
  description = "List of subnet names"
  value       = keys(azurerm_subnet.main)
}

output "route_table_ids" {
  description = "Map of route table names to their IDs"
  value = {
    for k, v in azurerm_route_table.main : k => v.id
  }
}

output "route_table_names" {
  description = "List of route table names"
  value       = keys(azurerm_route_table.main)
}

output "route_ids" {
  description = "Map of route keys to their IDs"
  value = {
    for k, v in azurerm_route.main : k => v.id
  }
}

output "subnet_route_table_associations" {
  description = "Map of subnet names to their associated route table IDs"
  value = {
    for k, v in azurerm_subnet_route_table_association.main : k => v.route_table_id
  }
}

