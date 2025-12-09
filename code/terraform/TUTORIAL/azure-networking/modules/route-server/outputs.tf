# ============================================================================
# Azure Route Server Module - Outputs
# ============================================================================
# Outputs expose important resource information for use by other modules
# or for reference in other Terraform configurations.
# ============================================================================

output "route_server_id" {
  description = "The ID of the Azure Route Server"
  value       = azurerm_route_server.main.id
}

output "route_server_name" {
  description = "The name of the Azure Route Server"
  value       = azurerm_route_server.main.name
}

output "route_server_fqdn" {
  description = "The fully qualified domain name (FQDN) of the Route Server"
  value       = azurerm_route_server.main.fqdn
}

output "route_server_public_ip_address" {
  description = "The public IP address of the Route Server"
  value       = azurerm_public_ip.route_server.ip_address
}

output "route_server_public_ip_id" {
  description = "The ID of the public IP address used by Route Server"
  value       = azurerm_public_ip.route_server.id
}

output "route_server_virtual_router_asn" {
  description = <<-EOT
    The Autonomous System Number (ASN) of the Route Server.
    Route Server always uses ASN 65515 (fixed, cannot be changed).
    NVAs must use a different ASN when peering with Route Server.
  EOT
  value       = azurerm_route_server.main.virtual_router_asn
}

output "route_server_virtual_router_ips" {
  description = <<-EOT
    The IP addresses of the Route Server's virtual router interfaces.
    These are the IP addresses that NVAs should peer with.
    Typically returns two IP addresses for high availability.
  EOT
  value       = azurerm_route_server.main.virtual_router_ips
}

output "bgp_peer_connection_ids" {
  description = "Map of BGP peer connection names to their IDs"
  value = {
    for key, peer in azurerm_route_server_bgp_connection.peers : key => peer.id
  }
}

output "resource_group_name" {
  description = "Name of the resource group (created or existing)"
  value       = local.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group if created by this module, null otherwise"
  value       = try(module.resource_group[0].resource_group_id, null)
}

