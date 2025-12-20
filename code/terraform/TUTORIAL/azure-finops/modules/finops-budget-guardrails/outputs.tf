# ============================================================================
# Azure FinOps Budget Guardrails Module - Outputs
# ============================================================================

output "budget_id" {
  description = "The ID of the created Budget (resource group or subscription scope)."
  value       = var.budget_scope == "resource_group" ? azurerm_consumption_budget_resource_group.budget[0].id : azurerm_consumption_budget_subscription.budget[0].id
}

output "budget_name" {
  description = "The name of the created Budget."
  value       = var.budget_name != null ? var.budget_name : (var.budget_scope == "resource_group" ? azurerm_consumption_budget_resource_group.budget[0].name : azurerm_consumption_budget_subscription.budget[0].name)
}

output "action_group_id" {
  description = "The ID of the Action Group used for alerts (created or existing)."
  value       = local.action_group_id
}

output "action_group_name" {
  description = "The name of the Action Group (if created)."
  value       = var.create_action_group ? azurerm_monitor_action_group.budget[0].name : null
}
