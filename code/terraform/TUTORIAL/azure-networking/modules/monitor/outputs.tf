# ============================================================================
# Azure Monitor Module - Outputs
# ============================================================================

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.main[0].id : null
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace"
  value       = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.main[0].name : null
}

output "log_analytics_workspace_primary_shared_key" {
  description = "The primary shared key for the Log Analytics workspace"
  value       = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.main[0].primary_shared_key : null
  sensitive   = true
}

output "log_analytics_workspace_secondary_shared_key" {
  description = "The secondary shared key for the Log Analytics workspace"
  value       = var.create_log_analytics_workspace ? azurerm_log_analytics_workspace.main[0].secondary_shared_key : null
  sensitive   = true
}

output "action_group_ids" {
  description = "Map of action group names to their IDs"
  value = {
    for k, v in azurerm_monitor_action_group.main : k => v.id
  }
}

output "metric_alert_ids" {
  description = "Map of metric alert names to their IDs"
  value = {
    for k, v in azurerm_monitor_metric_alert.main : k => v.id
  }
}

output "log_alert_ids" {
  description = "Map of log alert names to their IDs"
  value = {
    for k, v in azurerm_monitor_scheduled_query_rules_alert.main : k => v.id
  }
}

output "diagnostic_setting_ids" {
  description = "Map of diagnostic setting names to their IDs"
  value = {
    for k, v in azurerm_monitor_diagnostic_setting.main : k => v.id
  }
}

