# ============================================================================
# Azure FinOps Resource Scheduler Module - Outputs
# ============================================================================

output "automation_account_id" {
  description = "The ID of the Automation Account (created or existing)."
  value       = var.create_automation_account ? azurerm_automation_account.scheduler[0].id : null
}

output "automation_account_name" {
  description = "The name of the Automation Account."
  value       = local.automation_account_name
}

output "stop_runbook_id" {
  description = "The ID of the stop VMs runbook."
  value       = azurerm_automation_runbook.stop_vm.id
}

output "start_runbook_id" {
  description = "The ID of the start VMs runbook (if created)."
  value       = var.create_start_runbook ? azurerm_automation_runbook.start_vm[0].id : null
}

output "stop_schedule_id" {
  description = "The ID of the stop schedule."
  value       = azurerm_automation_schedule.stop_schedule.id
}

output "start_schedule_id" {
  description = "The ID of the start schedule (if created)."
  value       = var.create_start_runbook ? azurerm_automation_schedule.start_schedule[0].id : null
}
