# Route Server Module Usage

## Overview

The Azure Route Server module provides a comprehensive solution for managing Route Server and BGP peer connections. It follows the same pattern as other modules in this repository, using the resource-group module for consistent resource group management.

**Module Features:**
- Route Server creation with Standard SKU
- Automatic public IP creation
- BGP peer connections for NVAs
- Optional resource group creation
- Support for zone redundancy
- Branch-to-branch traffic configuration

## Module Location

```
modules/route-server/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

## Basic Usage

### With Existing Resource Group

```hcl
# Subnet for Route Server
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

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### With Resource Group Creation

```hcl
# Subnet for Route Server
resource "azurerm_subnet" "route_server" {
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/27"]
}

# Route Server Module
module "route_server" {
  source = "../../modules/route-server"

  create_resource_group = true
  project_name         = "networking"
  application_name     = "routeserver"
  environment          = "prod"
  location             = "West Europe"

  route_server_name = "rs-main"
  subnet_id         = azurerm_subnet.route_server.id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Complete Example with BGP Peers

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
  address_prefixes     = ["10.0.1.0/26"]
}

# NVA Subnet
resource "azurerm_subnet" "nva" {
  name                 = "NVASubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# NVA Network Interface
resource "azurerm_network_interface" "nva" {
  name                = "nic-nva"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.nva.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.10"
  }
}

# Route Server Module
module "route_server" {
  source = "../../modules/route-server"

  create_resource_group = false
  resource_group_name  = azurerm_resource_group.main.name
  location             = "West Europe"

  route_server_name                = "rs-main"
  subnet_id                        = azurerm_subnet.route_server.id
  branch_to_branch_traffic_enabled = true
  zones                            = ["1", "2", "3"]

  bgp_peers = {
    "nva-firewall" = {
      name     = "bgp-firewall"
      peer_asn = 65001
      peer_ip  = "10.0.2.10"
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Purpose     = "Dynamic Routing"
  }
}

# Outputs
output "route_server_ips" {
  description = "Route Server IP addresses for BGP peering"
  value       = module.route_server.route_server_virtual_router_ips
}

output "route_server_asn" {
  description = "Route Server ASN (for NVA configuration)"
  value       = module.route_server.route_server_virtual_router_asn
}
```

## Multiple BGP Peers

```hcl
module "route_server" {
  source = "../../modules/route-server"

  create_resource_group = false
  resource_group_name  = azurerm_resource_group.main.name
  location             = "West Europe"

  route_server_name = "rs-main"
  subnet_id         = azurerm_subnet.route_server.id

  bgp_peers = {
    "firewall-primary" = {
      name     = "bgp-firewall-primary"
      peer_asn = 65001
      peer_ip  = "10.0.2.10"
    }
    "firewall-secondary" = {
      name     = "bgp-firewall-secondary"
      peer_asn = 65001
      peer_ip  = "10.0.2.11"
    }
    "router" = {
      name     = "bgp-router"
      peer_asn = 65002
      peer_ip  = "10.0.2.20"
    }
  }

  tags = {
    Environment = "Production"
  }
}
```

## Zone-Redundant Configuration

```hcl
module "route_server" {
  source = "../../modules/route-server"

  create_resource_group = false
  resource_group_name  = azurerm_resource_group.main.name
  location             = "West Europe"

  route_server_name = "rs-main"
  subnet_id         = azurerm_subnet.route_server.id
  zones             = ["1", "2", "3"]  # Zone-redundant

  bgp_peers = {
    "nva-firewall" = {
      name     = "bgp-firewall"
      peer_asn = 65001
      peer_ip  = "10.0.2.10"
    }
  }

  tags = {
    Environment = "Production"
  }
}
```

## Module Variables

### Required Variables

- `route_server_name`: Name of the Route Server
- `subnet_id`: Subnet ID for Route Server

### Optional Variables

- `create_resource_group`: Whether to create resource group (default: `false`)
- `resource_group_name`: Existing resource group name
- `project_name`: Project name for resource group
- `application_name`: Application name for resource group
- `environment`: Environment name (default: `"dev"`)
- `location`: Azure region (default: `"Spain Central"`)
- `sku`: Route Server SKU (default: `"Standard"`)
- `branch_to_branch_traffic_enabled`: Enable branch-to-branch (default: `true`)
- `bgp_peers`: Map of BGP peer connections (default: `{}`)
- `zones`: Availability zones for public IP (default: `null`)
- `tags`: Tags for resources (default: `{}`)

## Module Outputs

### Available Outputs

```hcl
# Route Server Information
output "route_server_id" {
  value = module.route_server.route_server_id
}

output "route_server_name" {
  value = module.route_server.route_server_name
}

output "route_server_fqdn" {
  value = module.route_server.route_server_fqdn
}

# Public IP
output "route_server_public_ip" {
  value = module.route_server.route_server_public_ip_address
}

# BGP Information
output "route_server_asn" {
  value = module.route_server.route_server_virtual_router_asn
}

output "route_server_ips" {
  value = module.route_server.route_server_virtual_router_ips
}

# BGP Peers
output "bgp_peer_ids" {
  value = module.route_server.bgp_peer_connection_ids
}
```

### Using Outputs for NVA Configuration

```hcl
# Route Server Module
module "route_server" {
  source = "../../modules/route-server"
  # ... configuration ...
}

# Output Route Server information for NVA configuration
output "nva_bgp_config" {
  description = "BGP configuration information for NVA"
  value = {
    route_server_asn = module.route_server.route_server_virtual_router_asn
    route_server_ips = module.route_server.route_server_virtual_router_ips
  }
}
```

## Best Practices

### Module Usage

1. **Resource Groups**: Use dedicated resource groups for Route Server
2. **Subnet Sizing**: Use /26 or /25 for Route Server subnet
3. **Zone Redundancy**: Use zone-redundant public IP for production
4. **Branch-to-Branch**: Enable for hybrid scenarios
5. **Tagging**: Use consistent tags across resources

### BGP Peer Management

1. **Unique ASNs**: Use unique ASNs for different NVAs
2. **Static IPs**: Use static IP addresses for NVAs
3. **Documentation**: Document ASN assignments
4. **Monitoring**: Monitor BGP peer connections

## Troubleshooting

### Module Errors

**Error: Resource group not found**
- Set `create_resource_group = true` or provide existing `resource_group_name`
- Verify resource group exists and is accessible

**Error: Subnet not found**
- Verify subnet ID is correct
- Check subnet name is "RouteServerSubnet"
- Verify subnet size is /27 or larger

**Error: Invalid BGP peer ASN**
- Verify ASN is different from 65515
- Check ASN is a valid number

### Common Issues

**BGP peers not created**
- Verify Route Server is created first
- Check peer IP is correct
- Verify ASN is valid

**Routes not exchanging**
- Check BGP peer connection is established
- Verify NVA has BGP enabled
- Check IP forwarding is enabled on NVA

## Additional Resources

- [Route Server Module](../../../../modules/route-server/)
- [Module README](../../../../modules/route-server/README.md)
- [Azure Route Server Documentation](https://learn.microsoft.com/en-us/azure/route-server/)

