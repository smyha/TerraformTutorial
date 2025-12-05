# ============================================================================
# Azure Network Watcher Module - Outputs
# ============================================================================

output "network_watcher_id" {
  description = "The ID of the Network Watcher"
  value       = azurerm_network_watcher.main.id
}

output "network_watcher_name" {
  description = "The name of the Network Watcher"
  value       = azurerm_network_watcher.main.name
}

output "flow_log_ids" {
  description = "Map of flow log names to their IDs"
  value = {
    for key, log in azurerm_network_watcher_flow_log.main : key => log.id
  }
}

