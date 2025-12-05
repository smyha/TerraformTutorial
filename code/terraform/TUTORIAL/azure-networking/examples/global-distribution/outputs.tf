# ============================================================================
# Global Distribution Example - Outputs
# ============================================================================

output "traffic_manager_fqdn" {
  description = "FQDN of the Traffic Manager profile"
  value       = module.traffic_manager.traffic_manager_fqdn
}

output "front_door_cname" {
  description = "CNAME of the Front Door"
  value       = module.front_door.cname
}

output "cdn_endpoint_hostnames" {
  description = "Map of CDN endpoint names to their hostnames"
  value       = module.cdn.cdn_endpoint_hostnames
}

output "app_gateway_eastus_public_ip" {
  description = "Public IP address of the Application Gateway in East US"
  value       = azurerm_public_ip.appgw_eastus.ip_address
}

output "app_gateway_westeurope_public_ip" {
  description = "Public IP address of the Application Gateway in West Europe"
  value       = azurerm_public_ip.appgw_westeurope.ip_address
}

output "vnet_eastus_id" {
  description = "ID of the Virtual Network in East US"
  value       = module.vnet_eastus.vnet_id
}

output "vnet_westeurope_id" {
  description = "ID of the Virtual Network in West Europe"
  value       = module.vnet_westeurope.vnet_id
}

