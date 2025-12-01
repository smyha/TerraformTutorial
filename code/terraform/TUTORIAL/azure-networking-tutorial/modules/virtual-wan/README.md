# Azure Virtual WAN Module

This module creates a Virtual WAN with Virtual Hubs for centralized network connectivity.

## Features

- Hub-spoke architecture
- Branch connectivity (VPN, ExpressRoute)
- VNet connectivity
- Centralized security (Azure Firewall)
- SD-WAN integration
- Global reach

## Usage

```hcl
module "virtual_wan" {
  source = "./modules/virtual-wan"
  
  resource_group_name = "rg-example"
  location           = "eastus"
  
  virtual_wan_name = "vwan-main"
  type             = "Standard"
  
  allow_branch_to_branch_traffic = true
  
  virtual_hubs = {
    "hub-eastus" = {
      name                = "vhub-eastus"
      address_prefix      = "10.1.0.0/24"
      sku                 = "Standard"
      hub_routing_preference = "ExpressRoute"
    }
  }
}
```

## Outputs

- `virtual_wan_id`: The ID of the Virtual WAN
- `virtual_hub_ids`: Map of virtual hub names to IDs
- `virtual_hub_names`: Map of virtual hub names to resource names

