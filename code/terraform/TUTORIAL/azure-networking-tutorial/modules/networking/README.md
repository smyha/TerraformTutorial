# Azure Virtual Network Module

This module creates a complete Azure Virtual Network infrastructure with subnets, Network Security Groups (NSGs), and route tables.

## Features

- Virtual Network with configurable address spaces
- Multiple subnets with service endpoints and delegations
- Network Security Groups with custom rules
- Route tables with custom routes
- Optional DDoS Protection integration
- VM protection support

## Usage

```hcl
module "vnet" {
  source = "./modules/networking"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  vnet_name           = "prod-vnet"
  address_space       = ["10.0.0.0/16"]
  
  subnets = {
    "web-subnet" = {
      address_prefixes = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
    "app-subnet" = {
      address_prefixes = ["10.0.2.0/24"]
    }
    "db-subnet" = {
      address_prefixes = ["10.0.3.0/24"]
    }
  }
  
  network_security_groups = {
    "web-nsg" = {
      rules = [
        {
          name                       = "AllowHTTP"
          priority                   = 1000
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
      associate_to_subnets = ["web-subnet"]
    }
  }
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Requirements

- Terraform >= 1.0
- Azure Provider >= 3.0

## Inputs

See `variables.tf` for complete input documentation.

## Outputs

See `outputs.tf` for complete output documentation.
