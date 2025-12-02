# Azure NAT Gateway Module

This module creates an Azure NAT Gateway for outbound internet connectivity from subnets.

## Features

- Outbound-only NAT (SNAT - Source Network Address Translation)
- Up to 64,000 concurrent flows per public IP
- Automatic scaling
- No downtime during maintenance
- Zone-redundant (Standard SKU)
- Better performance than Load Balancer outbound rules
- No SNAT port exhaustion issues

## Usage

```hcl
# Create Public IP for NAT Gateway
resource "azurerm_public_ip" "nat" {
  name                = "pip-nat-gateway"
  location            = "eastus"
  resource_group_name = "rg-example"
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create NAT Gateway
module "nat_gateway" {
  source = "./modules/nat-gateway"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  nat_gateway_name     = "nat-main"
  
  # Public IP IDs (must be Standard SKU)
  public_ip_address_ids = [azurerm_public_ip.nat.id]
  
  # Optional: Idle timeout (4-120 minutes, default 4)
  idle_timeout_in_minutes = 4
  
  # Optional: Availability zones
  zones = ["1", "2", "3"]
  
  tags = {
    Environment = "Production"
  }
}

# Associate NAT Gateway with subnet
resource "azurerm_subnet_nat_gateway_association" "web" {
  subnet_id      = azurerm_subnet.web.id
  nat_gateway_id = module.nat_gateway.nat_gateway_id
}
```

## Requirements

- Public IP addresses (Standard SKU)
- Subnets to associate with NAT Gateway
- NAT Gateway must be associated with subnets using `azurerm_subnet_nat_gateway_association`

## Outputs

- `nat_gateway_id`: The ID of the NAT Gateway
- `nat_gateway_name`: The name of the NAT Gateway
- `nat_gateway_public_ip_address_ids`: List of public IP address IDs associated with the NAT Gateway

