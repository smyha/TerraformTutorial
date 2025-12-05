# Azure VPN Gateway Module

This module creates an Azure VPN Gateway for site-to-site, point-to-site, and VNet-to-VNet connectivity.

## Features

- Site-to-Site (S2S) VPN connectivity
- Point-to-Site (P2S) VPN connectivity
- VNet-to-VNet connectivity
- BGP support for dynamic routing
- Active-Active mode support
- ExpressRoute failover

## Usage

```hcl
module "vpn_gateway" {
  source = "./modules/vpn-gateway"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  vpn_gateway_name     = "vpn-gateway-main"
  
  vpn_type = "RouteBased"
  sku      = "VpnGw2"
  
  gateway_ip_configuration = {
    name      = "vnetGatewayConfig"
    subnet_id = azurerm_subnet.gateway.id
  }
  
  public_ip_configuration = {
    name              = "vpn-gateway-pip"
    allocation_method = "Static"
    sku               = "Standard"
  }
  
  enable_bgp = true
  bgp_settings = {
    asn = 65515
  }
}
```

## Requirements

- Gateway subnet (minimum /27 CIDR, named 'GatewaySubnet')
- Public IP address

## Outputs

- `vpn_gateway_id`: The ID of the VPN Gateway
- `public_ip_addresses`: List of public IP addresses
- `bgp_peering_addresses`: BGP peering addresses (if BGP enabled)
- `bgp_asn`: BGP ASN (if BGP enabled)

