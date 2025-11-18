# ================================================================================
# OUTPUT VARIABLES
# ================================================================================
# These outputs display information about the created resources

output "vm_id" {
  value       = azurerm_linux_virtual_machine.example.id
  description = "The ID of the Virtual Machine"
}

output "vm_name" {
  value       = azurerm_linux_virtual_machine.example.name
  description = "The name of the Virtual Machine"
}

output "vm_size" {
  value       = azurerm_linux_virtual_machine.example.vm_size
  description = "The size of the Virtual Machine (depends on workspace)"
}

output "resource_group_name" {
  value       = azurerm_resource_group.example.name
  description = "The name of the Resource Group"
}

output "private_ip_address" {
  value       = azurerm_network_interface.example.private_ip_addresses[0]
  description = "Private IP address of the VM"
}

output "ssh_public_key" {
  value       = tls_private_key.example.public_key_openssh
  description = "SSH public key for VM access (if auto-generated)"
  sensitive   = true
}

output "current_workspace" {
  value       = terraform.workspace
  description = "The currently active workspace"
}

output "vm_configuration_summary" {
  value = {
    workspace      = terraform.workspace
    vm_size        = azurerm_linux_virtual_machine.example.vm_size
    location       = azurerm_resource_group.example.location
    resource_group = azurerm_resource_group.example.name
  }
  description = "Summary of VM configuration for this workspace"
}
