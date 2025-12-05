# Implementing Public IP Addresses with Terraform

## Overview

Public IP addresses allow resources to communicate with the internet. They can be dynamically or statically assigned, depending on SKU.

## Terraform Implementation

### Basic Public IP (Standard SKU - Static)

```hcl
resource "azurerm_public_ip" "main" {
  name                = "pip-main"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = "Production"
  }
}
```

### Dynamic Public IP (Basic SKU)

```hcl
resource "azurerm_public_ip" "main" {
  name                = "pip-main"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}
```

### Zone-Redundant Public IP

```hcl
resource "azurerm_public_ip" "main" {
  name                = "pip-main"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]  # Zone-redundant
}
```

### IPv6 Public IP

```hcl
resource "azurerm_public_ip" "main" {
  name                = "pip-main"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv6"
}
```

## Key Configuration Parameters

| Parameter | Description | Required | Example |
|-----------|-------------|----------|---------|
| `name` | Public IP name | Yes | `pip-main` |
| `allocation_method` | Static or Dynamic | Yes | `Static` |
| `sku` | Basic or Standard | Yes | `Standard` |
| `ip_version` | IPv4 or IPv6 | No | `IPv4` |
| `zones` | Availability zones | No | `["1", "2", "3"]` |

## SKU Comparison

| Feature | Basic SKU | Standard SKU |
|---------|-----------|--------------|
| **Allocation** | Dynamic or Static | Static only |
| **Zones** | Limited support | Full support |
| **Security** | Not secure by default | Secure by default |
| **Use Case** | Dev/test | Production |

## Additional Resources

- [Public IP Addresses](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses)
- [Terraform azurerm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)


