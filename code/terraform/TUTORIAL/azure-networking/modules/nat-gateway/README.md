# Azure NAT Gateway Module

This module creates an Azure NAT Gateway for outbound internet connectivity from subnets.

## Overview

Azure Virtual NAT (NAT Gateway) allows internal resources in a private network to share routable IPv4 addresses. Instead of purchasing an IPv4 address for each resource that requires Internet access, you can use NAT Gateway to assign outbound requests from internal resources to an external IP address.

**Key Benefits:**
- **Cost Effective**: Share public IP addresses across multiple resources
- **Automatic Configuration**: No user-defined routes needed
- **High Performance**: Up to 50 Gbps throughput, 64,000 flows per public IP
- **Automatic Scaling**: Scales automatically to support dynamic workloads
- **Fully Managed**: No VMs or infrastructure to manage

## Features

- Outbound-only NAT (SNAT - Source Network Address Translation)
- Up to 64,000 concurrent flows per public IP
- Support for up to 16 public IP addresses or public IP prefixes
- Automatic scaling
- No downtime during maintenance
- Zone-redundant (Standard SKU)
- Better performance than Load Balancer outbound rules
- No SNAT port exhaustion issues
- Support for Public IP Prefix (contiguous IP ranges)

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

## Public IP Prefix Support

NAT Gateway also supports Public IP Prefix, which provides a contiguous range of public IP addresses:

```hcl
# Create Public IP Prefix
resource "azurerm_public_ip_prefix" "nat" {
  name                = "pip-prefix-nat"
  location            = "eastus"
  resource_group_name = "rg-example"
  prefix_length       = 28  # /28 = 16 IPs
  sku                 = "Standard"
}

# Create NAT Gateway with Public IP Prefix
module "nat_gateway" {
  source = "./modules/nat-gateway"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  nat_gateway_name     = "nat-main"
  
  # Use Public IP Prefix instead of individual IPs
  public_ip_prefix_ids = [azurerm_public_ip_prefix.nat.id]
  
  tags = {
    Environment = "Production"
  }
}
```

## Important Notes

### Limitations

- **IPv4 Only**: Only IPv4 address family is supported. NAT does not interact with IPv6.
- **Single VNet**: NAT Gateway cannot span multiple virtual networks. Each VNet needs its own NAT Gateway.
- **No IP Fragmentation**: IP fragmentation is not supported.

### Automatic Configuration

Once NAT Gateway is configured and associated with a subnet:
- All outbound UDP and TCP flows automatically use NAT
- No additional configuration needed
- No user-defined routes required
- NAT has priority over other outbound scenarios

### Capacity

- Up to 16 public IP addresses or public IP prefixes
- Up to 64,000 concurrent flows per public IP
- Up to 50 Gbps throughput per NAT Gateway
- Automatic scaling based on traffic

## Outputs

- `nat_gateway_id`: The ID of the NAT Gateway
- `nat_gateway_name`: The name of the NAT Gateway
- `nat_gateway_public_ip_address_ids`: List of public IP address IDs associated with the NAT Gateway
- `nat_gateway_public_ip_prefix_ids`: List of public IP prefix IDs associated with the NAT Gateway
- `nat_gateway_resource_guid`: The resource GUID property of the NAT Gateway

