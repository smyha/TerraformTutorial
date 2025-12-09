# Terraform Implementation Guides for Azure NAT Gateway

This directory contains comprehensive guides for implementing Azure NAT Gateway using Terraform.

## Documentation Structure

1. **[01-nat-gateway.md](./01-nat-gateway.md)**
   - Creating NAT Gateway
   - Public IP configuration
   - Basic setup

2. **[02-public-ip-prefix.md](./02-public-ip-prefix.md)**
   - Using Public IP Prefix
   - Contiguous IP ranges
   - Predictable outbound IPs

3. **[03-subnet-association.md](./03-subnet-association.md)**
   - Associating NAT Gateway with subnets
   - Multiple subnet configuration
   - Automatic routing

4. **[04-nat-gateway-module.md](./04-nat-gateway-module.md)**
   - Using the NAT Gateway module
   - Module configuration examples
   - Best practices

## Quick Start

### Basic NAT Gateway

```hcl
# Public IP
resource "azurerm_public_ip" "nat" {
  name                = "pip-nat"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NAT Gateway
resource "azurerm_nat_gateway" "main" {
  name                    = "nat-main"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
  
  public_ip_address_ids = [azurerm_public_ip.nat.id]
}

# Associate with subnet
resource "azurerm_subnet_nat_gateway_association" "web" {
  subnet_id      = azurerm_subnet.web.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}
```

## Module Usage

```hcl
module "nat_gateway" {
  source = "../../modules/nat-gateway"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  nat_gateway_name    = "nat-main"

  public_ip_address_ids = [azurerm_public_ip.nat.id]

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Additional Resources

- [NAT Gateway Module](../../../../modules/nat-gateway/README.md)
- [Azure NAT Gateway Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/nat-gateway/)
- [Terraform Azure NAT Gateway Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway)

