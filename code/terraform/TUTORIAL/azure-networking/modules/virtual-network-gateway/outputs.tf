# ============================================================================
# Azure Virtual Network Gateway Module - Outputs
# ============================================================================

output "gateway_id" {
  description = "The ID of the Virtual Network Gateway"
  value       = azurerm_virtual_network_gateway.main.id
}

output "gateway_name" {
  description = "The name of the Virtual Network Gateway"
  value       = azurerm_virtual_network_gateway.main.name
}

output "gateway_type" {
  description = "The type of the Virtual Network Gateway (Vpn or ExpressRoute)"
  value       = azurerm_virtual_network_gateway.main.type
}

output "public_ip_addresses" {
  description = "List of public IP addresses of the Virtual Network Gateway"
  value       = azurerm_public_ip.main[*].ip_address
}

output "public_ip_ids" {
  description = "List of public IP resource IDs"
  value       = azurerm_public_ip.main[*].id
}

output "bgp_peering_addresses" {
  description = "BGP peering addresses (if BGP is enabled)"
  value       = var.enable_bgp ? azurerm_virtual_network_gateway.main.bgp_settings[0].peering_addresses : null
}

output "bgp_asn" {
  description = "BGP ASN (if BGP is enabled)"
  value       = var.enable_bgp && var.bgp_settings != null ? var.bgp_settings.asn : null
}


