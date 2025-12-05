# ============================================================================
# Azure ExpressRoute Module - Outputs
# ============================================================================

output "express_route_circuit_id" {
  description = "The ID of the ExpressRoute circuit"
  value       = azurerm_express_route_circuit.main.id
}

output "express_route_circuit_name" {
  description = "The name of the ExpressRoute circuit"
  value       = azurerm_express_route_circuit.main.name
}

output "express_route_circuit_service_key" {
  description = "The service key of the ExpressRoute circuit (for provider provisioning)"
  value       = azurerm_express_route_circuit.main.service_key
  sensitive   = true
}

output "express_route_gateway_id" {
  description = "The ID of the ExpressRoute Gateway"
  value       = azurerm_virtual_network_gateway.expressroute.id
}

output "express_route_connection_id" {
  description = "The ID of the ExpressRoute connection"
  value       = azurerm_express_route_connection.main.id
}

output "gateway_public_ip_address" {
  description = "The public IP address of the ExpressRoute Gateway"
  value       = azurerm_public_ip.gateway.ip_address
}

