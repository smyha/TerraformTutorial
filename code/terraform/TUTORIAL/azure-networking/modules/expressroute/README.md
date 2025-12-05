# Azure ExpressRoute Module

This module creates an Azure ExpressRoute circuit and gateway for private connectivity to Azure.

## Features

- Private connectivity (not over Internet)
- High bandwidth (up to 100 Gbps)
- Predictable performance
- Global reach
- BGP support
- 99.95% uptime SLA

## Usage

```hcl
module "expressroute" {
  source = "./modules/expressroute"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  
  express_route_circuit_name = "er-circuit-main"
  service_provider_name      = "Colt"
  peering_location           = "London"
  bandwidth_in_mbps          = 1000
  
  sku = {
    tier   = "Standard"
    family = "MeteredData"
  }
  
  express_route_gateway_name = "gw-expressroute"
  gateway_sku                = "ErGw5AZ"
  
  gateway_ip_configuration = {
    name      = "vnetGatewayConfig"
    subnet_id = azurerm_subnet.gateway.id
  }
  
  gateway_public_ip_configuration = {
    name              = "er-gateway-pip"
    allocation_method = "Static"
    sku               = "Standard"
  }
  
  express_route_connection_name = "er-connection-main"
}
```

## Requirements

- Connectivity provider (e.g., Colt, Equinix)
- Gateway subnet (minimum /27 CIDR)
- ExpressRoute circuit must be provisioned by the connectivity provider

## Outputs

- `express_route_circuit_id`: The ID of the ExpressRoute circuit
- `express_route_circuit_service_key`: The service key (for provider provisioning)
- `express_route_gateway_id`: The ID of the ExpressRoute Gateway
- `gateway_public_ip_address`: The public IP address of the gateway

