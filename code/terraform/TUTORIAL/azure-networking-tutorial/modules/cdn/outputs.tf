# ============================================================================
# Azure CDN Module - Outputs
# ============================================================================

output "cdn_profile_id" {
  description = "The ID of the CDN profile"
  value       = azurerm_cdn_profile.main.id
}

output "cdn_profile_name" {
  description = "The name of the CDN profile"
  value       = azurerm_cdn_profile.main.name
}

output "cdn_endpoint_ids" {
  description = "Map of CDN endpoint names to their IDs"
  value = {
    for key, endpoint in azurerm_cdn_endpoint.main : key => endpoint.id
  }
}

output "cdn_endpoint_hostnames" {
  description = "Map of CDN endpoint names to their hostnames"
  value = {
    for key, endpoint in azurerm_cdn_endpoint.main : key => endpoint.host_name
  }
}

