# ============================================================================
# Azure Application Gateway Module - Outputs
# ============================================================================

output "application_gateway_id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

output "application_gateway_name" {
  description = "The name of the Application Gateway"
  value       = azurerm_application_gateway.main.name
}

output "application_gateway_fqdn" {
  description = "The FQDN of the Application Gateway (if public IP has domain name label)"
  value       = var.public_ip_enabled && var.public_ip_domain_name_label != null ? azurerm_public_ip.main[0].fqdn : null
}

output "public_ip_address" {
  description = "The public IP address of the Application Gateway"
  value       = var.public_ip_enabled ? azurerm_public_ip.main[0].ip_address : null
}

output "public_ip_id" {
  description = "The ID of the public IP address"
  value       = var.public_ip_enabled ? azurerm_public_ip.main[0].id : null
}

output "backend_address_pool_ids" {
  description = "Map of backend address pool names to their IDs"
  value = {
    for pool in azurerm_application_gateway.main.backend_address_pool : pool.name => pool.id
  }
}

output "backend_http_settings_ids" {
  description = "Map of backend HTTP settings names to their IDs"
  value = {
    for setting in azurerm_application_gateway.main.backend_http_settings : setting.name => setting.id
  }
}

output "frontend_ip_configuration_ids" {
  description = "Map of frontend IP configuration names to their IDs"
  value = {
    for config in azurerm_application_gateway.main.frontend_ip_configuration : config.name => config.id
  }
}

output "http_listener_ids" {
  description = "Map of HTTP listener names to their IDs"
  value = {
    for listener in azurerm_application_gateway.main.http_listener : listener.name => listener.id
  }
}

output "request_routing_rule_ids" {
  description = "Map of request routing rule names to their IDs"
  value = {
    for rule in azurerm_application_gateway.main.request_routing_rule : rule.name => rule.id
  }
}

