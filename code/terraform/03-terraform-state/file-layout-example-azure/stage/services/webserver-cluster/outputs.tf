output "load_balancer_public_ip" {
  value       = azurerm_public_ip.webserver_cluster.ip_address
  description = "The public IP address of the load balancer"
}

output "load_balancer_fqdn" {
  value       = azurerm_public_ip.webserver_cluster.fqdn
  description = "The fully qualified domain name of the load balancer public IP"
}

output "vmss_id" {
  value       = azurerm_linux_virtual_machine_scale_set.webserver_cluster.id
  description = "The resource ID of the Virtual Machine Scale Set"
}

output "vmss_name" {
  value       = azurerm_linux_virtual_machine_scale_set.webserver_cluster.name
  description = "The name of the Virtual Machine Scale Set"
}

output "backend_address_pool_id" {
  value       = azurerm_lb_backend_address_pool.webserver_cluster.id
  description = "The resource ID of the load balancer backend address pool"
}

output "backend_address_pool_backend_ip_configurations" {
  value       = azurerm_lb_backend_address_pool.webserver_cluster.backend_ip_configurations
  description = "The backend IP configurations in the backend address pool"
}
