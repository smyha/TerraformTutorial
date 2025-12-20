# ============================================================================
# Azure FinOps Tagging Policy Module - Outputs
# ============================================================================

output "policy_definition_id" {
  description = "The ID of the created Policy Definition."
  value       = azurerm_policy_definition.tagging.id
}

output "policy_definition_name" {
  description = "The name of the created Policy Definition."
  value       = azurerm_policy_definition.tagging.name
}

output "policy_assignment_id" {
  description = "The ID of the Policy Assignment (subscription, management group, or resource group scope)."
  value = var.assignment_scope == "subscription" ? azurerm_subscription_policy_assignment.tagging[0].id : (
    var.assignment_scope == "management_group" ? azurerm_management_group_policy_assignment.tagging[0].id : (
      var.assignment_scope == "resource_group" ? azurerm_resource_group_policy_assignment.tagging[0].id : null
    )
  )
}

output "policy_assignment_name" {
  description = "The name of the Policy Assignment."
  value = var.assignment_scope == "subscription" ? azurerm_subscription_policy_assignment.tagging[0].name : (
    var.assignment_scope == "management_group" ? azurerm_management_group_policy_assignment.tagging[0].name : (
      var.assignment_scope == "resource_group" ? azurerm_resource_group_policy_assignment.tagging[0].name : null
    )
  )
}

output "required_tags" {
  description = "List of required tag names."
  value       = [for tag in var.required_tags : tag.name]
}
