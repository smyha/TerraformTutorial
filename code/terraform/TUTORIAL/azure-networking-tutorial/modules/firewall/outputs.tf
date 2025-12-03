# ============================================================================
# Azure Firewall Module - Outputs
# ============================================================================

output "firewall_id" {
  description = "The ID of the Azure Firewall"
  value       = azurerm_firewall.main.id
}

output "firewall_name" {
  description = "The name of the Azure Firewall"
  value       = azurerm_firewall.main.name
}

output "firewall_private_ip" {
  description = "The private IP address of the Azure Firewall"
  value       = azurerm_firewall.main.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "The public IP address of the Azure Firewall"
  value       = azurerm_firewall.main.ip_configuration[0].public_ip_address_id
}

