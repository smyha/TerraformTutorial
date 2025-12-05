# Azure Traffic Manager Module

This module creates a Traffic Manager profile for DNS-based traffic load balancing.

## Features

- DNS-based load balancing
- Multiple routing methods (Priority, Weighted, Performance, Geographic, Subnet, MultiValue)
- Health monitoring
- Automatic failover
- Global distribution

## Usage

```hcl
module "traffic_manager" {
  source = "./modules/traffic-manager"
  
  resource_group_name = "rg-example"
  location            = "global"
  
  traffic_manager_profile_name = "tm-global-app"
  traffic_routing_method        = "Priority"
  
  dns_config = {
    relative_name = "global-app"
    ttl           = 60
  }
  
  monitor_config = {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/health"
    interval_in_seconds           = 30
    timeout_in_seconds            = 10
    tolerated_number_of_failures = 3
  }
  
  endpoints = [
    {
      name               = "eastus-endpoint"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.east.id
      priority           = 1
      enabled            = true
    }
  ]
}
```

## Outputs

- `traffic_manager_profile_id`: The ID of the Traffic Manager profile
- `traffic_manager_fqdn`: The FQDN of the Traffic Manager profile
- `endpoint_ids`: Map of endpoint names to IDs

