# Implementing Private IP Addresses with Terraform

## Overview

Private IP addresses enable communication within an Azure virtual network and on-premises networks. They are allocated from the subnet's address range.

## Terraform Implementation

### Dynamic Private IP Assignment

```hcl
# Network Interface with Dynamic IP
resource "azurerm_network_interface" "main" {
  name                = "nic-main"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"  # Default
  }
}
```

### Static Private IP Assignment

```hcl
# Network Interface with Static IP
resource "azurerm_network_interface" "main" {
  name                = "nic-main"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"  # Must be available
  }
}
```

### When to Use Static Private IPs

Use static private IP addresses for:
- DNS name resolution
- IP address-based security models
- TLS/SSL certificates linked to IP
- Firewall rules using IP ranges
- Domain Controllers and DNS servers

## Additional Resources

- [Private IP Addresses](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/private-ip-addresses)
- [Terraform azurerm_network_interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)


