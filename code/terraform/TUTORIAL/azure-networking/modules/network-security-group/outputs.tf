# ============================================================================
# Azure Network Security Group Module - Outputs
# ============================================================================

output "nsg_id" {
  description = "The ID of the Network Security Group"
  value       = azurerm_network_security_group.main.id
}

output "nsg_name" {
  description = "The name of the Network Security Group"
  value       = azurerm_network_security_group.main.name
}

output "security_rule_ids" {
  description = "Map of security rule names to their IDs"
  value = {
    for k, v in azurerm_network_security_rule.main : k => v.id
  }
}

output "associated_subnet_ids" {
  description = "List of subnet IDs associated with this NSG"
  value       = var.associate_to_subnets
}


