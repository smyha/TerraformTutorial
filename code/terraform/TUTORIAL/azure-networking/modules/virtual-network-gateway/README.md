# Azure Virtual Network Gateway Module

This module creates an Azure Virtual Network Gateway for VPN or ExpressRoute connectivity.

## Features

- VPN Gateway: Site-to-Site, Point-to-Site, VNet-to-VNet VPN
- ExpressRoute Gateway: Private, dedicated connectivity
- Active-active mode support (high availability)
- BGP routing support
- Point-to-Site VPN configuration (VPN Gateway only)
- Zone-redundant public IPs

## Usage

### VPN Gateway (Site-to-Site)

```hcl
module "vpn_gateway" {
  source = "./modules/virtual-network-gateway"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  gateway_name        = "vpn-gateway"
  gateway_type        = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw2"
  
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
    asn             = 65515
    peer_weight     = 0
    peering_addresses = []
  }
  
  tags = {
    Environment = "Production"
  }
}
```

### VPN Gateway (Point-to-Site)

```hcl
module "vpn_gateway" {
  source = "./modules/virtual-network-gateway"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  gateway_name        = "vpn-gateway"
  gateway_type        = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw2"
  
  gateway_ip_configuration = {
    name      = "vnetGatewayConfig"
    subnet_id = azurerm_subnet.gateway.id
  }
  
  public_ip_configuration = {
    name              = "vpn-gateway-pip"
    allocation_method = "Static"
    sku               = "Standard"
  }
  
  vpn_client_configuration = {
    address_space = ["172.16.0.0/24"]
    root_certificates = [
      {
        name             = "root-cert"
        public_cert_data = file("root-cert.pem")
      }
    ]
    vpn_client_protocols = ["OpenVPN", "IkeV2"]
  }
  
  tags = {
    Environment = "Production"
  }
}
```

### ExpressRoute Gateway

```hcl
module "expressroute_gateway" {
  source = "./modules/virtual-network-gateway"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  gateway_name        = "er-gateway"
  gateway_type        = "ExpressRoute"
  sku                 = "HighPerformance"
  
  gateway_ip_configuration = {
    name      = "vnetGatewayConfig"
    subnet_id = azurerm_subnet.gateway.id
  }
  
  public_ip_configuration = {
    name              = "er-gateway-pip"
    allocation_method = "Static"
    sku               = "Standard"
  }
  
  enable_bgp = true
  bgp_settings = {
    asn             = 65515
    peer_weight     = 0
    peering_addresses = []
  }
  
  tags = {
    Environment = "Production"
  }
}
```

### Active-Active VPN Gateway

```hcl
module "vpn_gateway" {
  source = "./modules/virtual-network-gateway"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  gateway_name        = "vpn-gateway"
  gateway_type        = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw2"
  active_active       = true  # Requires two public IPs
  
  gateway_ip_configuration = {
    name      = "vnetGatewayConfig"
    subnet_id = azurerm_subnet.gateway.id
  }
  
  public_ip_configuration = {
    name              = "vpn-gateway-pip"
    allocation_method = "Static"
    sku               = "Standard"
    zones             = ["1", "2", "3"]  # Zone redundancy
  }
  
  enable_bgp = true
  bgp_settings = {
    asn             = 65515
    peer_weight     = 0
    peering_addresses = []
  }
  
  tags = {
    Environment = "Production"
  }
}
```

## Important Notes

### Gateway Subnet Requirements

- **Name**: Must be named `GatewaySubnet`
- **Minimum size**: `/27` (32 IP addresses)
- **Recommended**: `/26` (64 addresses) for high-performance SKUs
- **Dedicated**: Cannot contain other resources

### SKU Selection

**VPN Gateway SKUs:**
- `Basic`: Development/testing only (no BGP, limited tunnels)
- `VpnGw2`: Recommended for most production scenarios
- `VpnGw4/VpnGw5`: High-performance scenarios

**ExpressRoute Gateway SKUs:**
- `Standard`: Up to 10 Gbps
- `HighPerformance`: Up to 20 Gbps
- `UltraPerformance`: Up to 100 Gbps

### Active-Active Mode

- Requires two public IP addresses
- Provides higher availability and load balancing
- Automatic failover if one gateway fails
- Both gateways are active simultaneously

### BGP Configuration

- Required for ExpressRoute Gateway
- Recommended for advanced VPN scenarios
- Provides dynamic routing and automatic failover
- Requires ASN (Autonomous System Number)

## Requirements

- Gateway subnet must exist (named `GatewaySubnet`)
- Gateway subnet must be at least `/27` CIDR
- Public IP addresses (created by module)
- For ExpressRoute: ExpressRoute circuit must be created separately

## Outputs

- `gateway_id`: The ID of the Virtual Network Gateway
- `gateway_name`: The name of the Virtual Network Gateway
- `gateway_type`: The type of the gateway (Vpn or ExpressRoute)
- `public_ip_addresses`: List of public IP addresses
- `public_ip_ids`: List of public IP resource IDs
- `bgp_peering_addresses`: BGP peering addresses (if BGP enabled)
- `bgp_asn`: BGP ASN (if BGP enabled)

## Additional Resources

- [VPN Gateway Documentation](https://learn.microsoft.com/en-us/azure/vpn-gateway/)
- [ExpressRoute Gateway Documentation](https://learn.microsoft.com/en-us/azure/expressroute/)
- [Virtual Network Gateway SKUs](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings)


