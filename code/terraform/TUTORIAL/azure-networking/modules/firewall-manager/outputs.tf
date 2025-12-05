# ============================================================================
# Azure Firewall Manager Module - Outputs
# ============================================================================

output "firewall_policy_id" {
  description = "The ID of the Firewall Policy"
  value       = azurerm_firewall_policy.main.id
}

output "firewall_policy_name" {
  description = "The name of the Firewall Policy"
  value       = azurerm_firewall_policy.main.name
}

output "rule_collection_group_ids" {
  description = "Map of rule collection group names to their IDs"
  value = {
    for key, group in azurerm_firewall_policy_rule_collection_group.main : key => group.id
  }
}

