# ============================================================================
# Hybrid Connectivity Example - Outputs
# ============================================================================

output "vpn_gateway_public_ip" {
  description = "Public IP address of the VPN Gateway"
  value       = module.vpn_gateway.public_ip_addresses[0]
}

output "vpn_gateway_bgp_peering_address" {
  description = "BGP peering address of the VPN Gateway"
  value       = module.vpn_gateway.bgp_peering_addresses
}

output "vpn_gateway_bgp_asn" {
  description = "BGP ASN of the VPN Gateway"
  value       = module.vpn_gateway.bgp_asn
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.vnet.vnet_id
}

output "gateway_subnet_id" {
  description = "ID of the Gateway Subnet"
  value       = module.vnet.subnet_ids["gateway-subnet"]
}

output "local_network_gateway_id" {
  description = "ID of the Local Network Gateway"
  value       = azurerm_local_network_gateway.on_premises.id
}

output "vpn_connection_id" {
  description = "ID of the VPN Connection"
  value       = azurerm_virtual_network_gateway_connection.on_premises.id
}

