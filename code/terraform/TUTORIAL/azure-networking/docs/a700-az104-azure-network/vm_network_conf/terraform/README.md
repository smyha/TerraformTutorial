# Terraform Implementation Guides for Azure Virtual Network Configuration

This directory contains comprehensive guides for implementing Azure Virtual Network configurations using Terraform.

## Documentation Structure

1. **[01-virtual-network.md](./01-virtual-network.md)**
   - Creating virtual networks
   - Address space configuration
   - Subnet planning

2. **[02-vnet-peering.md](./02-vnet-peering.md)**
   - Regional peering
   - Global peering
   - Gateway transit

## Quick Start

```hcl
# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "subnet-main"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}
```

## Additional Resources

- [Azure Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)
- [Terraform Azure Provider - Virtual Network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)

