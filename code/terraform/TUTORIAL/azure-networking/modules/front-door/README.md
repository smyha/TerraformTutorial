# Azure Front Door Module

This module creates an Azure Front Door profile for global application delivery.

## Features

- Global load balancing
- WAF protection
- SSL/TLS termination
- Edge caching
- URL rewrite
- Health probes
- Session affinity

## Usage

```hcl
module "front_door" {
  source = "./modules/front-door"
  
  resource_group_name = "rg-example"
  location            = "global"
  
  front_door_name = "fd-global-app"
  friendly_name   = "Global Application Front Door"
  
  backend_pools = [
    {
      name                = "web-backend"
      health_probe_name   = "http-probe"
      load_balancing_name = "lb-settings"
      backends = [
        {
          host_header = "www.example.com"
          address     = "10.0.1.10"
          http_port   = 80
          https_port  = 443
          priority    = 1
          weight      = 50
          enabled     = true
        }
      ]
    }
  ]
  
  frontend_endpoints = [
    {
      name      = "www-endpoint"
      host_name = "www.example.com"
    }
  ]
  
  routing_rules = [
    {
      name               = "http-rule"
      frontend_endpoints  = ["www-endpoint"]
      accepted_protocols  = ["Http", "Https"]
      patterns_to_match   = ["/*"]
      route_configuration = {
        forwarding_protocol = "MatchRequest"
        backend_pool_name   = "web-backend"
        cache_enabled       = false
      }
    }
  ]
}
```

## Outputs

- `front_door_id`: The ID of the Front Door
- `front_door_name`: The name of the Front Door
- `frontend_endpoint_hostnames`: Map of frontend endpoint names to hostnames
- `cname`: The CNAME of the Front Door

