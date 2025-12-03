# ============================================================================
# Azure Virtual WAN Module - Outputs
# ============================================================================

output "virtual_wan_id" {
  description = "The ID of the Virtual WAN"
  value       = azurerm_virtual_wan.main.id
}

output "virtual_wan_name" {
  description = "The name of the Virtual WAN"
  value       = azurerm_virtual_wan.main.name
}

output "virtual_hub_ids" {
  description = "Map of virtual hub names to their IDs"
  value = {
    for key, hub in azurerm_virtual_hub.main : key => hub.id
  }
}

output "virtual_hub_names" {
  description = "Map of virtual hub names to their resource names"
  value = {
    for key, hub in azurerm_virtual_hub.main : key => hub.name
  }
}

