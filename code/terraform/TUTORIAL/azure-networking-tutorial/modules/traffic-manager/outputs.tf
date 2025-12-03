# ============================================================================
# Azure Traffic Manager Module - Outputs
# ============================================================================

output "traffic_manager_profile_id" {
  description = "The ID of the Traffic Manager profile"
  value       = azurerm_traffic_manager_profile.main.id
}

output "traffic_manager_profile_name" {
  description = "The name of the Traffic Manager profile"
  value       = azurerm_traffic_manager_profile.main.name
}

output "traffic_manager_fqdn" {
  description = "The FQDN of the Traffic Manager profile"
  value       = azurerm_traffic_manager_profile.main.fqdn
}

output "endpoint_ids" {
  description = "Map of endpoint names to their IDs"
  value = {
    for key, endpoint in azurerm_traffic_manager_endpoint.main : key => endpoint.id
  }
}

