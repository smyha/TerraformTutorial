# Using the Front Door Module

This guide explains how to use the Azure Front Door Terraform module for creating and managing Front Door profiles.

## Module Overview

The Front Door module provides a reusable way to create Front Door profiles with backend pools, routing rules, frontend endpoints, and WAF configuration.

**Module Location:** `modules/front-door/`

## Basic Module Usage

### Simple Front Door Configuration

```hcl
module "front_door" {
  source = "../../modules/front-door"

  resource_group_name = azurerm_resource_group.main.name
  location            = "global"
  front_door_name     = "fd-global-app"
  friendly_name       = "Global Application Front Door"

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
          weight      = 100
          enabled     = true
        }
      ]
    }
  ]

  backend_pool_health_probes = [
    {
      name                = "http-probe"
      protocol            = "Http"
      path                = "/health"
      interval_in_seconds = 30
      enabled             = true
    }
  ]

  backend_pool_load_balancing = [
    {
      name                            = "lb-settings"
      sample_size                     = 4
      successful_samples_required     = 2
      additional_latency_milliseconds = 0
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

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Multi-Region Backend Example

```hcl
module "front_door" {
  source = "../../modules/front-door"

  resource_group_name = azurerm_resource_group.main.name
  location            = "global"
  front_door_name     = "fd-global-app"
  friendly_name       = "Global Application Front Door"

  backend_pools = [
    {
      name                = "multi-region-backend"
      health_probe_name   = "http-probe"
      load_balancing_name = "lb-settings"
      backends = [
        {
          host_header = "www.example.com"
          address     = "10.0.1.10"  # US East
          http_port   = 80
          https_port  = 443
          priority    = 1
          weight      = 50
          enabled     = true
        },
        {
          host_header = "www.example.com"
          address     = "10.1.1.10"  # Europe
          http_port   = 80
          https_port  = 443
          priority    = 1
          weight      = 30
          enabled     = true
        },
        {
          host_header = "www.example.com"
          address     = "10.2.1.10"  # Asia
          http_port   = 80
          https_port  = 443
          priority    = 1
          weight      = 20
          enabled     = true
        }
      ]
    }
  ]

  backend_pool_health_probes = [
    {
      name                = "http-probe"
      protocol            = "Http"
      path                = "/health"
      interval_in_seconds = 30
      enabled             = true
    }
  ]

  backend_pool_load_balancing = [
    {
      name                            = "lb-settings"
      sample_size                     = 4
      successful_samples_required     = 2
      additional_latency_milliseconds = 0
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
      name               = "https-rule"
      frontend_endpoints  = ["www-endpoint"]
      accepted_protocols  = ["Https"]
      patterns_to_match   = ["/*"]
      route_configuration = {
        forwarding_protocol = "MatchRequest"
        backend_pool_name   = "multi-region-backend"
        cache_enabled       = false
      }
    }
  ]
}
```

## Path-Based Routing Example

```hcl
module "front_door" {
  source = "../../modules/front-door"

  resource_group_name = azurerm_resource_group.main.name
  location            = "global"
  front_door_name     = "fd-global-app"
  friendly_name       = "Global Application Front Door"

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
          weight      = 100
          enabled     = true
        }
      ]
    },
    {
      name                = "api-backend"
      health_probe_name   = "http-probe"
      load_balancing_name = "lb-settings"
      backends = [
        {
          host_header = "api.example.com"
          address     = "10.0.2.10"
          http_port   = 80
          https_port  = 443
          priority    = 1
          weight      = 100
          enabled     = true
        }
      ]
    },
    {
      name                = "static-backend"
      health_probe_name   = "http-probe"
      load_balancing_name = "lb-settings"
      backends = [
        {
          host_header = "static.example.com"
          address     = "10.0.3.10"
          http_port   = 80
          https_port  = 443
          priority    = 1
          weight      = 100
          enabled     = true
        }
      ]
    }
  ]

  backend_pool_health_probes = [
    {
      name                = "http-probe"
      protocol            = "Http"
      path                = "/health"
      interval_in_seconds = 30
      enabled             = true
    }
  ]

  backend_pool_load_balancing = [
    {
      name                            = "lb-settings"
      sample_size                     = 4
      successful_samples_required     = 2
      additional_latency_milliseconds = 0
    }
  ]

  frontend_endpoints = [
    {
      name      = "www-endpoint"
      host_name = "www.example.com"
    }
  ]

  routing_rules = [
    # HTTP to HTTPS Redirect
    {
      name               = "http-redirect"
      frontend_endpoints  = ["www-endpoint"]
      accepted_protocols  = ["Http"]
      patterns_to_match   = ["/*"]
      route_configuration = {
        redirect_type     = "Moved"
        redirect_protocol = "HttpsOnly"
        redirect_host     = "www.example.com"
        redirect_path     = "/{path}"
        redirect_query_string = "{query}"
      }
    },
    # API Path
    {
      name               = "api-rule"
      frontend_endpoints  = ["www-endpoint"]
      accepted_protocols  = ["Https"]
      patterns_to_match   = ["/api/*"]
      route_configuration = {
        forwarding_protocol = "MatchRequest"
        backend_pool_name   = "api-backend"
        cache_enabled       = false
      }
    },
    # Static Content (with caching)
    {
      name               = "static-rule"
      frontend_endpoints  = ["www-endpoint"]
      accepted_protocols  = ["Https"]
      patterns_to_match   = ["/static/*", "/images/*", "/css/*", "/js/*"]
      route_configuration = {
        forwarding_protocol         = "MatchRequest"
        backend_pool_name            = "static-backend"
        cache_enabled                = true
        cache_duration                = "P30D"
        compression_enabled           = true
      }
    },
    # Default (web content)
    {
      name               = "web-rule"
      frontend_endpoints  = ["www-endpoint"]
      accepted_protocols  = ["Https"]
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

## Module Outputs

The module provides the following outputs:

```hcl
# Get Front Door CNAME
output "front_door_cname" {
  value = module.front_door.cname
}

# Get Front Door ID
output "front_door_id" {
  value = module.front_door.front_door_id
}

# Get Front Door Name
output "front_door_name" {
  value = module.front_door.front_door_name
}

# Get Frontend Endpoint Hostnames
output "frontend_endpoint_hostnames" {
  value = module.front_door.frontend_endpoint_hostnames
}
```

## Using Module Outputs

### Create DNS CNAME Record

```hcl
# Front Door Module
module "front_door" {
  source = "../../modules/front-door"
  # ... configuration ...
}

# DNS Zone
resource "azurerm_dns_zone" "main" {
  name                = "example.com"
  resource_group_name = azurerm_resource_group.main.name
}

# CNAME Record pointing to Front Door
resource "azurerm_dns_cname_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  record              = module.front_door.cname
}
```

## Best Practices

1. **Use Modules**: Use the module for consistency and reusability
2. **Configure Health Probes**: Always configure appropriate health monitoring
3. **Enable HTTPS**: Always enable HTTPS for custom domains
4. **Use Caching**: Enable caching for static content
5. **Tag Resources**: Add meaningful tags for organization
6. **Use Variables**: Parameterize configuration for different environments
7. **Monitor Outputs**: Use module outputs for integration with other resources

## Module Variables Reference

### Required Variables

- `resource_group_name`: Name of the resource group
- `front_door_name`: Name of the Front Door (globally unique)
- `backend_pools`: List of backend pools
- `backend_pool_health_probes`: List of health probes
- `backend_pool_load_balancing`: List of load balancing settings
- `frontend_endpoints`: List of frontend endpoints
- `routing_rules`: List of routing rules

### Optional Variables

- `location`: Location (default: "global")
- `friendly_name`: Friendly name for Front Door
- `load_balancer_enabled`: Enable load balancing (default: true)
- `tags`: Map of tags (default: {})

## Additional Resources

- [Front Door Module](../../../../modules/front-door/README.md)
- [Front Door Module Source](../../../../modules/front-door/)
- [Azure Front Door Documentation](https://learn.microsoft.com/en-us/azure/frontdoor/)

