# Azure Virtual Network Module

This module creates an Azure Virtual Network (VNet) with configurable subnets, service endpoints, and optional DDoS protection.

## Features

- Virtual Network with configurable address spaces
- Subnets with service endpoints
- Service delegation support (AKS, App Service, etc.)
- Private endpoint and private link service network policies
- Optional DDoS Protection integration
- Custom DNS server configuration

## Usage

### Basic Virtual Network

```hcl
module "virtual_network" {
  source = "./modules/virtual-network"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  vnet_name           = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  
  subnets = {
    "subnet-web" = {
      address_prefixes = ["10.0.1.0/24"]
    }
    "subnet-app" = {
      address_prefixes = ["10.0.2.0/24"]
    }
    "subnet-db" = {
      address_prefixes = ["10.0.3.0/24"]
    }
  }
  
  tags = {
    Environment = "Production"
  }
}
```

### Virtual Network with Service Endpoints

```hcl
module "virtual_network" {
  source = "./modules/virtual-network"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  vnet_name           = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  
  subnets = {
    "subnet-web" = {
      address_prefixes = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
    "subnet-app" = {
      address_prefixes = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.Sql", "Microsoft.KeyVault"]
    }
  }
  
  tags = {
    Environment = "Production"
  }
}
```

### Virtual Network with Gateway Subnet

```hcl
module "virtual_network" {
  source = "./modules/virtual-network"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  vnet_name           = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  
  subnets = {
    "GatewaySubnet" = {
      address_prefixes = ["10.0.0.0/27"]  # Minimum /27 for VPN/ExpressRoute Gateway
    }
    "subnet-web" = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}
```

### Virtual Network with Custom DNS

```hcl
module "virtual_network" {
  source = "./modules/virtual-network"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  vnet_name           = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  
  dns_servers = ["10.0.0.4", "10.0.0.5"]  # Custom DNS servers
  
  subnets = {
    "subnet-web" = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}
```

### Virtual Network with Service Delegation (AKS)

```hcl
module "virtual_network" {
  source = "./modules/virtual-network"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  vnet_name           = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  
  subnets = {
    "subnet-aks" = {
      address_prefixes = ["10.0.1.0/24"]
      delegation = {
        name = "aks-delegation"
        service_delegation = {
          name    = "Microsoft.ContainerService/managedClusters"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    }
  }
}
```

## Important Notes

### Reserved IP Addresses

Azure reserves 5 IP addresses per subnet:
- **First address**: Network address (e.g., 10.0.1.0)
- **Second address**: Default gateway (e.g., 10.0.1.1)
- **Third and fourth**: Azure DNS (e.g., 10.0.1.2, 10.0.1.3)
- **Last address**: Broadcast address (e.g., 10.0.1.255)

Example: A `/24` subnet (256 addresses) has 251 usable addresses.

### Address Space Planning

- **Cannot be changed**: Address space cannot be modified after creation
- **No overlap**: Must not overlap with on-premises networks if connecting via VPN/ExpressRoute
- **Future growth**: Plan for future expansion and connectivity requirements
- **Subnet sizing**: Account for reserved addresses when planning subnet sizes

### Gateway Subnet

If you plan to use VPN Gateway or ExpressRoute Gateway:
- Subnet must be named `GatewaySubnet`
- Minimum size: `/27` (32 addresses)
- Recommended: `/26` (64 addresses) for high-performance SKUs

## Requirements

- Resource group must exist
- Address space must be valid CIDR notation
- Subnet address prefixes must be within VNet address space
- Subnet address prefixes must not overlap

## Outputs

- `virtual_network_id`: The ID of the Virtual Network
- `virtual_network_name`: The name of the Virtual Network
- `virtual_network_address_space`: The address space of the Virtual Network
- `subnet_ids`: Map of subnet names to their IDs
- `subnet_address_prefixes`: Map of subnet names to their address prefixes
- `subnet_names`: List of subnet names

## Additional Resources

- [Azure Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)
- [Subnet Planning Guide](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-vnet-plan-design-guide)
- [Service Endpoints](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview)


