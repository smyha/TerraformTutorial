# Creating Azure Route Server

## Overview

Azure Route Server is a fully managed service that enables dynamic routing between Network Virtual Appliances (NVAs) and Azure Virtual Networks using BGP.

**Key Requirements:**
- Dedicated subnet named "RouteServerSubnet"
- Subnet size: minimum /27, recommended /26 or /25
- Public IP address (Standard SKU)
- Standard SKU for production

## Subnet Preparation

### Creating RouteServerSubnet

The subnet name must be exactly "RouteServerSubnet" (case-sensitive).

```hcl
# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Route Server Subnet
resource "azurerm_subnet" "route_server" {
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/27"]  # Minimum /27
}
```

### Subnet Sizing

**Minimum Size: /27**
- Provides 32 IP addresses
- ~29 usable addresses (after Azure reserved addresses)
- Suitable for single Route Server

**Recommended Size: /26**
- Provides 64 IP addresses
- ~61 usable addresses
- Better for future growth

**Large Deployments: /25**
- Provides 128 IP addresses
- ~125 usable addresses
- For complex scenarios

```hcl
# Recommended subnet size
resource "azurerm_subnet" "route_server" {
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/26"]  # Recommended /26
}
```

## Public IP Address

Route Server requires a Standard SKU public IP address.

```hcl
resource "azurerm_public_ip" "route_server" {
  name                = "pip-routeserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]  # Zone-redundant for HA
}
```

## Creating Route Server

### Basic Configuration

```hcl
resource "azurerm_route_server" "main" {
  name                = "rs-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  subnet_id           = azurerm_subnet.route_server.id
  public_ip_address_id = azurerm_public_ip.route_server.id
}
```

### With Branch-to-Branch Traffic

Enable branch-to-branch traffic to allow route exchange with VPN Gateway and ExpressRoute Gateway.

```hcl
resource "azurerm_route_server" "main" {
  name                = "rs-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  subnet_id           = azurerm_subnet.route_server.id
  public_ip_address_id = azurerm_public_ip.route_server.id

  branch_to_branch_traffic_enabled = true
}
```

### Zone-Redundant Configuration

For high availability, use zone-redundant public IP.

```hcl
# Zone-redundant Public IP
resource "azurerm_public_ip" "route_server" {
  name                = "pip-routeserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

# Route Server
resource "azurerm_route_server" "main" {
  name                = "rs-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  subnet_id           = azurerm_subnet.route_server.id
  public_ip_address_id = azurerm_public_ip.route_server.id
}
```

## Complete Example

```hcl
# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-routeserver"
  location = "West Europe"
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Route Server Subnet
resource "azurerm_subnet" "route_server" {
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/26"]
}

# Public IP
resource "azurerm_public_ip" "route_server" {
  name                = "pip-routeserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

# Route Server
resource "azurerm_route_server" "main" {
  name                = "rs-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  subnet_id           = azurerm_subnet.route_server.id
  public_ip_address_id = azurerm_public_ip.route_server.id

  branch_to_branch_traffic_enabled = true

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Outputs
output "route_server_id" {
  description = "Route Server resource ID"
  value       = azurerm_route_server.main.id
}

output "route_server_asn" {
  description = "Route Server ASN (always 65515)"
  value       = azurerm_route_server.main.virtual_router_asn
}

output "route_server_ips" {
  description = "Route Server virtual router IP addresses"
  value       = azurerm_route_server.main.virtual_router_ips
}
```

## Route Server Properties

### ASN (Autonomous System Number)

Route Server always uses ASN **65515**. This cannot be changed.

```hcl
output "route_server_asn" {
  value = azurerm_route_server.main.virtual_router_asn  # Always 65515
}
```

### Virtual Router IPs

Route Server provides two IP addresses for high availability.

```hcl
output "route_server_ips" {
  description = "IP addresses for BGP peering"
  value       = azurerm_route_server.main.virtual_router_ips
}
```

**Example Output:**
```
route_server_ips = [
  "10.0.1.4",
  "10.0.1.5"
]
```

NVAs should peer with both IP addresses for redundancy.

## Best Practices

1. **Subnet Naming**: Always use exact name "RouteServerSubnet"
2. **Subnet Size**: Use /26 or /25 for future growth
3. **Dedicated Subnet**: Don't deploy other resources in RouteServerSubnet
4. **Standard SKU**: Always use Standard SKU for production
5. **Zone Redundancy**: Use zone-redundant public IP for HA
6. **Branch-to-Branch**: Enable if using VPN/ExpressRoute Gateways

## Troubleshooting

### Subnet Name Error

**Error**: "Subnet name must be RouteServerSubnet"

**Solution**: Verify subnet name is exactly "RouteServerSubnet" (case-sensitive)

### Subnet Size Error

**Error**: "Subnet size must be /27 or larger"

**Solution**: Use /27, /26, or /25 subnet size

### Public IP SKU Error

**Error**: "Public IP must be Standard SKU"

**Solution**: Use `sku = "Standard"` for public IP

## Additional Resources

- [Route Server Requirements](https://learn.microsoft.com/en-us/azure/route-server/quickstart-configure-route-server)
- [Terraform azurerm_route_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_server)

