# ============================================================================
# Multi-Tier Application Example - Outputs
# ============================================================================

output "application_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.appgw.ip_address
}

output "application_gateway_fqdn" {
  description = "FQDN of the Application Gateway (if configured)"
  value       = azurerm_public_ip.appgw.fqdn
}

output "load_balancer_public_ip" {
  description = "Public IP address of the Load Balancer"
  value       = azurerm_public_ip.lb.ip_address
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.vnet.vnet_id
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.vnet.subnet_ids
}

output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = azurerm_public_ip.nat_gateway.ip_address
}

