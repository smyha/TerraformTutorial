# Azure Route Server Module

This Terraform module creates an Azure Route Server with BGP peer connections for Network Virtual Appliances (NVAs).

## Overview

Azure Route Server simplifies dynamic routing between Network Virtual Appliances (NVAs) and Virtual Networks. It is a fully managed service configured with high availability, which simplifies the configuration, management, and deployment of NVAs in the virtual network.

**Key Simplifications:**
- **No manual route table updates**: You no longer need to manually update routing tables in NVAs when VNet addresses change
- **No manual user-defined routes**: Routes are automatically learned and propagated when NVAs advertise/withdraw routes
- **Multiple NVA support**: You can peer multiple instances of your NVA with Azure Route Server
- **Standard BGP protocol**: Works with any NVA that supports BGP
- **Flexible deployment**: Can be deployed in new or existing virtual networks

## Features

- Creates Azure Route Server with Standard SKU
- Automatic public IP address creation
- BGP peer connections for NVAs
- Optional resource group creation
- Support for zone redundancy
- Branch-to-branch traffic configuration
- Fully managed service with high availability

## Usage

### Basic Example

```hcl
# Create subnet for Route Server
resource "azurerm_subnet" "route_server" {
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/27"]
}

# Route Server Module
module "route_server" {
  source = "../../modules/route-server"

  create_resource_group = false
  resource_group_name  = azurerm_resource_group.main.name
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
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Complete Example with Resource Group

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

  sku                              = "Standard"
  branch_to_branch_traffic_enabled = true
  zones                            = ["1", "2", "3"]

  bgp_peers = {
    "nva-firewall-primary" = {
      name     = "bgp-firewall-primary"
      peer_asn = 65001
      peer_ip  = "10.0.1.10"
    }
    "nva-firewall-secondary" = {
      name     = "bgp-firewall-secondary"
      peer_asn = 65001
      peer_ip  = "10.0.1.11"
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Purpose     = "Dynamic Routing"
  }
}
```

## Requirements

### Subnet Requirements

- **Name**: Must be exactly "RouteServerSubnet" (case-sensitive)
- **Size**: Minimum /27, recommended /26 or /25
- **Dedicated**: Should only contain Route Server (no other resources)
- **Location**: Must be in the VNet where you want dynamic routing

### NVA Requirements

- Must have BGP enabled and configured
- Must have IP forwarding enabled on network interface
- Must use a unique ASN (different from Route Server's ASN 65515)
- Must be in the same VNet or a peered VNet

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `create_resource_group` | Whether to create a resource group | `bool` | `false` | no |
| `resource_group_name` | Existing resource group name | `string` | `null` | no |
| `project_name` | Project name for resource group | `string` | `""` | no |
| `application_name` | Application name for resource group | `string` | `""` | no |
| `environment` | Environment name | `string` | `"dev"` | no |
| `location` | Azure region | `string` | `"Spain Central"` | no |
| `route_server_name` | Name of the Route Server | `string` | n/a | yes |
| `sku` | Route Server SKU | `string` | `"Standard"` | no |
| `subnet_id` | Subnet ID for Route Server | `string` | n/a | yes |
| `branch_to_branch_traffic_enabled` | Enable branch-to-branch traffic | `bool` | `true` | no |
| `bgp_peers` | Map of BGP peer connections | `map(object)` | `{}` | no |
| `zones` | Availability zones for public IP | `list(string)` | `null` | no |
| `tags` | Tags for resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `route_server_id` | Route Server resource ID |
| `route_server_name` | Route Server name |
| `route_server_fqdn` | Route Server FQDN |
| `route_server_public_ip_address` | Public IP address |
| `route_server_virtual_router_asn` | Route Server ASN (65515) |
| `route_server_virtual_router_ips` | Virtual router IP addresses |
| `bgp_peer_connection_ids` | BGP peer connection IDs |
| `resource_group_name` | Resource group name |

## Route Server ASN

Azure Route Server always uses ASN **65515**. This cannot be changed. All NVAs must use a different ASN when peering with Route Server.

## BGP Peer Configuration

Each NVA requires a BGP peer connection with:
- **peer_asn**: NVA's ASN (must be different from 65515)
- **peer_ip**: NVA's IP address in the VNet
- **name**: Unique name for the BGP connection

## Branch-to-Branch Traffic

When `branch_to_branch_traffic_enabled = true`, Route Server can exchange routes between:
- Azure VPN Gateway
- ExpressRoute Gateway
- NVAs via BGP

This enables dynamic routing in hybrid scenarios.

## Additional Resources

- [Azure Route Server Documentation](https://learn.microsoft.com/en-us/azure/route-server/overview)
- [Route Server with NVA](https://learn.microsoft.com/en-us/azure/route-server/quickstart-configure-route-server)
- [BGP Configuration](https://learn.microsoft.com/en-us/azure/route-server/route-server-faq)

