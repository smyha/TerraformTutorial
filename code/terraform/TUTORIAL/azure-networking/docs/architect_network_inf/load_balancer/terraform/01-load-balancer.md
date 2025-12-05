# Implementing Azure Load Balancer with Terraform

## Overview

Azure Load Balancer distributes traffic across multiple virtual machines. Supports both external (public) and internal (private) configurations.

## Terraform Implementation

### External Load Balancer

```hcl
# Public IP
resource "azurerm_public_ip" "lb" {
  name                = "pip-lb"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Load Balancer
resource "azurerm_lb" "main" {
  name                = "lb-main"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}
```

### Internal Load Balancer

```hcl
# Load Balancer
resource "azurerm_lb" "internal" {
  name                = "lb-internal"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "InternalIPAddress"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.10"
    subnet_id                     = azurerm_subnet.backend.id
  }
}
```

## Key Configuration Parameters

| Parameter | Description | Required | Example |
|-----------|-------------|----------|---------|
| `name` | Load balancer name | Yes | `lb-main` |
| `location` | Azure region | Yes | `eastus` |
| `resource_group_name` | Resource group | Yes | Resource group name |
| `sku` | Basic or Standard | Yes | `Standard` |
| `frontend_ip_configuration` | Frontend IP config | Yes | See frontend block |

## Additional Resources

- [Load Balancer Overview](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview)
- [Terraform azurerm_lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb)

