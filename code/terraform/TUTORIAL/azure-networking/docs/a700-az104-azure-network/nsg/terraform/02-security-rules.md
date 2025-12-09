# Implementing NSG Security Rules with Terraform

## Overview

Security rules allow or deny traffic based on five-tuple matching: source IP, source port, destination IP, destination port, and protocol.

## Terraform Implementation

### Basic Security Rule

```hcl
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "AllowHTTP"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}
```

### Multiple Security Rules

```hcl
# Allow HTTP
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "AllowHTTP"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Allow HTTPS
resource "azurerm_network_security_rule" "allow_https" {
  name                        = "AllowHTTPS"
  priority                    = 1010
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Deny specific IP range
resource "azurerm_network_security_rule" "deny_range" {
  name                        = "DenyIPRange"
  priority                    = 900
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "192.168.100.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}
```

## Key Configuration Parameters

| Parameter | Description | Required | Example |
|-----------|-------------|----------|---------|
| `name` | Rule name | Yes | `AllowHTTP` |
| `priority` | Rule priority (100-4096) | Yes | `1000` |
| `direction` | Inbound or Outbound | Yes | `Inbound` |
| `access` | Allow or Deny | Yes | `Allow` |
| `protocol` | Tcp, Udp, Icmp, or * | Yes | `Tcp` |
| `source_port_range` | Source port(s) | Yes | `*` or `80` |
| `destination_port_range` | Destination port(s) | Yes | `80` or `80-443` |
| `source_address_prefix` | Source IP/CIDR | Yes | `Internet` or `10.0.0.0/24` |
| `destination_address_prefix` | Destination IP/CIDR | Yes | `*` or `10.0.1.0/24` |

## Additional Resources

- [NSG Security Rules](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview#security-rules)
- [Terraform azurerm_network_security_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)

