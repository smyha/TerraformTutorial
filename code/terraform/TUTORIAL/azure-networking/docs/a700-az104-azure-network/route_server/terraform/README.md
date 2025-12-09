# Terraform Implementation Guides for Azure Route Server

This directory contains comprehensive guides for implementing Azure Route Server using Terraform.

## Documentation Structure

1. **[01-route-server.md](./01-route-server.md)**
   - Creating Route Server
   - Subnet requirements
   - Basic configuration

2. **[02-bgp-peers.md](./02-bgp-peers.md)**
   - BGP peer connections
   - NVA configuration
   - Multiple peer setup

3. **[03-nva-integration.md](./03-nva-integration.md)**
   - NVA deployment with Route Server
   - BGP configuration on NVAs
   - IP forwarding setup

4. **[04-hybrid-connectivity.md](./04-hybrid-connectivity.md)**
   - Integration with VPN Gateway
   - ExpressRoute Gateway integration
   - Branch-to-branch traffic

5. **[05-route-server-module.md](./05-route-server-module.md)**
   - Using the Route Server module
   - Module configuration examples
   - Best practices

## Quick Start

### Basic Route Server

```hcl
# Subnet for Route Server
resource "azurerm_subnet" "route_server" {
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/27"]
}

# Public IP for Route Server
resource "azurerm_public_ip" "route_server" {
  name                = "pip-routeserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
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

### Route Server with BGP Peer

```hcl
# Route Server
resource "azurerm_route_server" "main" {
  name                = "rs-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  subnet_id           = azurerm_subnet.route_server.id
  public_ip_address_id = azurerm_public_ip.route_server.id
}

# BGP Peer Connection (NVA)
resource "azurerm_route_server_bgp_connection" "nva" {
  name            = "bgp-nva-firewall"
  route_server_id = azurerm_route_server.main.id
  peer_asn        = 65001
  peer_ip         = "10.0.1.10"  # NVA IP address
}
```

## Module Usage

```hcl
module "route_server" {
  source = "../../modules/route-server"

  create_resource_group = true
  project_name         = "networking"
  application_name     = "routeserver"
  environment          = "prod"
  location             = "West Europe"

  route_server_name = "rs-main"
  subnet_id         = azurerm_subnet.route_server.id

  bgp_peers = {
    "nva-firewall" = {
      name     = "bgp-firewall"
      peer_asn = 65001
      peer_ip  = "10.0.1.10"
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Additional Resources

- [Route Server Module](../../../../modules/route-server/README.md)
- [Azure Route Server Documentation](https://learn.microsoft.com/en-us/azure/route-server/)
- [Terraform Azure Route Server Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_server)

