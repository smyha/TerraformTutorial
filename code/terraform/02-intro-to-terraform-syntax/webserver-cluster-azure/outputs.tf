# ============================================================================
# Output Values for Web Server Cluster
# ============================================================================
# These outputs provide important information about the deployed infrastructure
# that can be used by other modules or displayed to the user.
# ============================================================================

output "vmss_id" {
  description = "Resource ID of the Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.web_servers.id
}

output "vmss_name" {
  description = "Name of the Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.web_servers.name
}

output "resource_group_name" {
  description = "Name of the Resource Group"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "Resource ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "subnet_id" {
  description = "Resource ID of the Subnet"
  value       = azurerm_subnet.main.id
}

output "ssh_private_key" {
  description = "Private SSH key for connecting to VMs (save this securely)"
  value       = tls_private_key.main.private_key_openssh
  sensitive   = true
}

output "ssh_public_key" {
  description = "Public SSH key used for VM authentication"
  value       = tls_private_key.main.public_key_openssh
}

output "autoscale_setting_id" {
  description = "Resource ID of the autoscale setting"
  value       = azurerm_monitor_autoscale_setting.web_servers.id
}

output "nsg_id" {
  description = "Resource ID of the Network Security Group"
  value       = azurerm_network_security_group.main.id
}
