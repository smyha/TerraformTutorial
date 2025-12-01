# ============================================================================
# Azure DDoS Protection Module - Outputs
# ============================================================================

output "ddos_protection_plan_id" {
  description = "The ID of the DDoS Protection Plan"
  value       = azurerm_network_ddos_protection_plan.main.id
}

output "ddos_protection_plan_name" {
  description = "The name of the DDoS Protection Plan"
  value       = azurerm_network_ddos_protection_plan.main.name
}

