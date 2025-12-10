# Front Door Edge Caching

This guide explains how to configure edge caching in Azure Front Door using Terraform.

## Overview

Azure Front Door provides edge caching capabilities to improve performance and reduce backend load by caching content at edge locations worldwide.

## Basic Caching Configuration

### Enable Caching for Static Content

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  routing_rule {
    name               = "static-rule"
    frontend_endpoints = ["www-endpoint"]
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/static/*", "/images/*", "/css/*", "/js/*"]

    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "static-backend"
      cache_enabled       = true  # Enable caching
    }
  }
}
```

## Cache Configuration Parameters

### Cache Duration

```hcl
routing_rule {
  name               = "cached-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/static/*"]

  forwarding_configuration {
    forwarding_protocol = "MatchRequest"
    backend_pool_name   = "static-backend"
    cache_enabled       = true
    cache_duration      = "P1D"  # Cache for 1 day (ISO 8601 duration)
  }
}
```

**Cache Duration Format:**
- ISO 8601 duration format
- Examples: `P1D` (1 day), `P7D` (7 days), `PT1H` (1 hour)

### Cache Query Parameter Handling

```hcl
routing_rule {
  name               = "query-cache-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/*"]

  forwarding_configuration {
    forwarding_protocol              = "MatchRequest"
    backend_pool_name                = "web-backend"
    cache_enabled                    = true
    cache_query_parameter_strip_directive = "StripAll"  # Remove all query params
  }
}
```

**Query Parameter Options:**
- `StripAll`: Remove all query parameters from cache key
- `StripNone`: Keep all query parameters in cache key
- `StripOnly`: Remove only specified query parameters

### Compression Configuration

```hcl
routing_rule {
  name               = "compression-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/*"]

  forwarding_configuration {
    forwarding_protocol         = "MatchRequest"
    backend_pool_name           = "web-backend"
    cache_enabled               = true
    cache_use_dynamic_compression = true  # Enable compression
  }
}
```

## Cache Rules by Content Type

### Static Content Caching

```hcl
# Images, CSS, JavaScript
routing_rule {
  name               = "static-assets"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/images/*", "/css/*", "/js/*", "/fonts/*"]

  forwarding_configuration {
    forwarding_protocol              = "MatchRequest"
    backend_pool_name                = "static-backend"
    cache_enabled                    = true
    cache_duration                   = "P30D"  # Cache for 30 days
    cache_query_parameter_strip_directive = "StripAll"
    cache_use_dynamic_compression    = true
  }
}
```

### Dynamic Content (No Caching)

```hcl
# API endpoints - no caching
routing_rule {
  name               = "api-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/api/*"]

  forwarding_configuration {
    forwarding_protocol = "MatchRequest"
    backend_pool_name   = "api-backend"
    cache_enabled       = false  # Disable caching for dynamic content
  }
}
```

### HTML Pages (Short Cache)

```hcl
# HTML pages - short cache duration
routing_rule {
  name               = "html-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/*.html", "/*.htm"]

  forwarding_configuration {
    forwarding_protocol              = "MatchRequest"
    backend_pool_name                = "web-backend"
    cache_enabled                    = true
    cache_duration                   = "PT1H"  # Cache for 1 hour
    cache_query_parameter_strip_directive = "StripAll"
  }
}
```

## Cache Purging

Cache purging allows you to manually invalidate cached content.

### Cache Purge Configuration

```hcl
# Note: Cache purging is typically done via Azure CLI or Portal
# Terraform doesn't have a direct resource for cache purging

# Example Azure CLI command:
# az frontdoor purge-endpoint --resource-group rg-front-door --name fd-global-app --content-paths "/*"
```

**Cache Purge Methods:**
- **Azure CLI**: `az frontdoor purge-endpoint`
- **Azure Portal**: Front Door → Endpoints → Purge
- **REST API**: Front Door purge endpoint API

## Complete Caching Example

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name
  friendly_name       = "Global Application Front Door"
  load_balancer_enabled = true

  # Frontend Endpoint
  frontend_endpoint {
    name      = "www-endpoint"
    host_name = "www.example.com"
  }

  # Backend Pools
  backend_pool {
    name                = "static-backend"
    health_probe_name   = "http-probe"
    load_balancing_name = "lb-settings"
    # ... backend configuration ...
  }

  backend_pool {
    name                = "web-backend"
    health_probe_name   = "http-probe"
    load_balancing_name = "lb-settings"
    # ... backend configuration ...
  }

  # Health Probe
  backend_pool_health_probe {
    name                = "http-probe"
    protocol            = "Http"
    path                = "/health"
    interval_in_seconds = 30
    enabled             = true
  }

  # Load Balancing Settings
  backend_pool_load_balancing {
    name                            = "lb-settings"
    sample_size                     = 4
    successful_samples_required     = 2
    additional_latency_milliseconds = 0
  }

  # Routing Rule 1: Static Assets (Long Cache)
  routing_rule {
    name               = "static-assets"
    frontend_endpoints = ["www-endpoint"]
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/images/*", "/css/*", "/js/*", "/fonts/*"]

    forwarding_configuration {
      forwarding_protocol              = "MatchRequest"
      backend_pool_name                = "static-backend"
      cache_enabled                    = true
      cache_duration                   = "P30D"  # 30 days
      cache_query_parameter_strip_directive = "StripAll"
      cache_use_dynamic_compression    = true
    }
  }

  # Routing Rule 2: HTML Pages (Short Cache)
  routing_rule {
    name               = "html-pages"
    frontend_endpoints = ["www-endpoint"]
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*.html", "/*.htm"]

    forwarding_configuration {
      forwarding_protocol              = "MatchRequest"
      backend_pool_name                = "web-backend"
      cache_enabled                    = true
      cache_duration                   = "PT1H"  # 1 hour
      cache_query_parameter_strip_directive = "StripAll"
    }
  }

  # Routing Rule 3: API (No Cache)
  routing_rule {
    name               = "api-rule"
    frontend_endpoints = ["www-endpoint"]
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/api/*"]

    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "web-backend"
      cache_enabled       = false  # No caching for API
    }
  }

  # Routing Rule 4: Default (No Cache)
  routing_rule {
    name               = "default-rule"
    frontend_endpoints = ["www-endpoint"]
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]

    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "web-backend"
      cache_enabled       = false
    }
  }
}
```

## Cache Best Practices

1. **Cache Static Content**: Enable caching for static assets (images, CSS, JS)
2. **Long Cache Duration**: Use long cache durations for immutable static content
3. **Short Cache for HTML**: Use shorter cache durations for HTML pages
4. **No Cache for Dynamic**: Disable caching for API endpoints and dynamic content
5. **Query Parameter Handling**: Strip query parameters for static content
6. **Enable Compression**: Use compression to reduce bandwidth
7. **Cache Purging**: Plan for cache purging when content updates

## Additional Resources

- [Front Door Caching](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-caching)
- [Front Door Cache Rules](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-caching-rules)
- [Front Door Cache Purging](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-caching-purging)

