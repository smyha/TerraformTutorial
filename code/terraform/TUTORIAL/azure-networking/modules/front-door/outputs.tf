# ============================================================================
# Azure Front Door Module - Outputs
# ============================================================================

output "front_door_id" {
  description = "The ID of the Front Door"
  value       = azurerm_frontdoor.main.id
}

output "front_door_name" {
  description = "The name of the Front Door"
  value       = azurerm_frontdoor.main.name
}

output "frontend_endpoint_hostnames" {
  description = "Map of frontend endpoint names to their hostnames"
  value = {
    for endpoint in azurerm_frontdoor.main.frontend_endpoint : endpoint.name => endpoint.host_name
  }
}

output "cname" {
  description = "The CNAME of the Front Door (for DNS configuration)"
  value       = azurerm_frontdoor.main.cname
}

