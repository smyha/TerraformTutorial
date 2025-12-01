# ============================================================================
# Azure Private Link Module - Outputs
# ============================================================================

output "private_endpoint_ids" {
  description = "Map of private endpoint names to their IDs"
  value = {
    for key, endpoint in azurerm_private_endpoint.main : key => endpoint.id
  }
}

output "private_endpoint_private_ip_addresses" {
  description = "Map of private endpoint names to their private IP addresses"
  value = {
    for key, endpoint in azurerm_private_endpoint.main : key => endpoint.private_ip_address
  }
}

output "private_link_service_ids" {
  description = "Map of private link service names to their IDs"
  value = {
    for key, service in azurerm_private_link_service.main : key => service.id
  }
}

output "private_link_service_aliases" {
  description = "Map of private link service names to their aliases (for connection)"
  value = {
    for key, service in azurerm_private_link_service.main : key => service.alias
  }
}

