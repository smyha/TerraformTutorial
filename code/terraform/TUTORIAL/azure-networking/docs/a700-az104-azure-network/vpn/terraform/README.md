# Terraform Implementation Guides for Azure VPN Gateway

This directory contains comprehensive guides for implementing Azure VPN Gateway services using Terraform.

## Documentation Structure

1. **[01-vpn-gateway.md](./01-vpn-gateway.md)**
   - Creating VPN gateways
   - Gateway SKU selection
   - Gateway subnet configuration

2. **[02-vpn-connections.md](./02-vpn-connections.md)**
   - Site-to-site connections
   - Point-to-site connections
   - VNet-to-VNet connections

3. **[03-local-network-gateway.md](./03-local-network-gateway.md)**
   - Local network gateway configuration
   - On-premises network definition

## Quick Start

```hcl
# VPN Gateway
resource "azurerm_virtual_network_gateway" "main" {
  name                = "vpn-gateway"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
}
```

## Additional Resources

- [Azure VPN Gateway Documentation](https://learn.microsoft.com/en-us/azure/vpn-gateway/)
- [Terraform Azure Provider - VPN Gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway)

