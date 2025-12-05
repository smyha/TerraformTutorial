# ============================================================================
# Azure NAT Gateway Module - Outputs
# ============================================================================

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = azurerm_nat_gateway.main.id
}

output "nat_gateway_name" {
  description = "The name of the NAT Gateway"
  value       = azurerm_nat_gateway.main.name
}

output "nat_gateway_public_ip_address_ids" {
  description = "List of public IP address IDs associated with the NAT Gateway"
  value       = azurerm_nat_gateway.main.public_ip_address_ids
}

