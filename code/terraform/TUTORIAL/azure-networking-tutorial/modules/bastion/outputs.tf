# ============================================================================
# Azure Bastion Module - Outputs
# ============================================================================

output "bastion_id" {
  description = "The ID of the Azure Bastion host"
  value       = azurerm_bastion_host.main.id
}

output "bastion_name" {
  description = "The name of the Azure Bastion host"
  value       = azurerm_bastion_host.main.name
}

output "bastion_dns_name" {
  description = "The FQDN of the Azure Bastion host"
  value       = azurerm_bastion_host.main.dns_name
}

