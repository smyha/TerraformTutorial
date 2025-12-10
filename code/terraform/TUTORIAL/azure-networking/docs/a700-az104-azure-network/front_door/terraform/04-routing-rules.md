# Front Door Routing Rules

This guide explains how to configure routing rules in Azure Front Door using Terraform.

## Overview

Routing rules determine how requests are processed and where they are routed. They match incoming requests based on protocol, hostname, and path, then perform actions like forwarding to backends or redirecting.

## Routing Algorithm

Azure Front Door routing algorithm matches requests in the following order:

1. **HTTP Protocol** (HTTP/HTTPS)
2. **Frontend Host** (Hostname, e.g., `www.example.com`, `*.example.com`)
3. **Path** (URL Path, e.g., `/`, `/users/`, `/file.gif`)

More specific matches take precedence, and the first matching rule is applied.

## Basic Routing Rule

### Forward to Backend

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  # Frontend Endpoint
  frontend_endpoint {
    name      = "www-endpoint"
    host_name = "www.example.com"
  }

  # Backend Pool
  backend_pool {
    name                = "web-backend"
    health_probe_name   = "http-probe"
    load_balancing_name = "lb-settings"
    # ... backend configuration ...
  }

  # Routing Rule
  routing_rule {
    name               = "http-rule"
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

## Routing Rule Types

### Forward Configuration

Forward requests to a backend pool.

```hcl
routing_rule {
  name               = "forward-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/*"]

  forwarding_configuration {
    forwarding_protocol = "MatchRequest"  # or "HttpOnly", "HttpsOnly"
    backend_pool_name   = "web-backend"
    cache_enabled       = false
  }
}
```

**Forwarding Protocol Options:**
- `MatchRequest`: Use the same protocol as the request
- `HttpOnly`: Always use HTTP
- `HttpsOnly`: Always use HTTPS

### Redirect Configuration

Redirect requests to another URL.

```hcl
routing_rule {
  name               = "redirect-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http"]
  patterns_to_match  = ["/*"]

  redirect_configuration {
    redirect_type     = "Moved"  # or "Found", "TemporaryRedirect", "PermanentRedirect"
    redirect_protocol = "HttpsOnly"
    custom_host       = "www.example.com"
    custom_path       = "/"
    custom_query_string = ""
    custom_fragment   = ""
  }
}
```

**Redirect Types:**
- `Moved`: 301 Permanent Redirect
- `Found`: 302 Temporary Redirect
- `TemporaryRedirect`: 307 Temporary Redirect
- `PermanentRedirect`: 308 Permanent Redirect

## Match Conditions

### Protocol Matching

```hcl
routing_rule {
  name               = "https-only-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Https"]  # Only HTTPS
  patterns_to_match  = ["/*"]

  forwarding_configuration {
    forwarding_protocol = "MatchRequest"
    backend_pool_name   = "web-backend"
    cache_enabled       = false
  }
}
```

### Hostname Matching

```hcl
# Multiple frontend endpoints
frontend_endpoint {
  name      = "www-endpoint"
  host_name = "www.example.com"
}

frontend_endpoint {
  name      = "api-endpoint"
  host_name = "api.example.com"
}

# Routing rule for www
routing_rule {
  name               = "www-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/*"]

  forwarding_configuration {
    forwarding_protocol = "MatchRequest"
    backend_pool_name   = "web-backend"
    cache_enabled       = false
  }
}

# Routing rule for api
routing_rule {
  name               = "api-rule"
  frontend_endpoints = ["api-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/*"]

  forwarding_configuration {
    forwarding_protocol = "MatchRequest"
    backend_pool_name   = "api-backend"
    cache_enabled       = false
  }
}
```

### Path-Based Routing

```hcl
# Root path rule
routing_rule {
  name               = "root-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/"]

  forwarding_configuration {
    forwarding_protocol = "MatchRequest"
    backend_pool_name   = "web-backend"
    cache_enabled       = false
  }
}

# API path rule
routing_rule {
  name               = "api-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/api/*"]

  forwarding_configuration {
    forwarding_protocol = "MatchRequest"
    backend_pool_name   = "api-backend"
    cache_enabled       = false
  }
}

# Static content rule
routing_rule {
  name               = "static-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/static/*", "/images/*", "/css/*", "/js/*"]

  forwarding_configuration {
    forwarding_protocol = "MatchRequest"
    backend_pool_name   = "static-backend"
    cache_enabled       = true  # Enable caching for static content
  }
}
```

## HTTP to HTTPS Redirection

### Redirect HTTP to HTTPS

```hcl
# HTTP listener - redirect to HTTPS
routing_rule {
  name               = "http-to-https-redirect"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http"]  # Only HTTP
  patterns_to_match  = ["/*"]

  redirect_configuration {
    redirect_type     = "Moved"
    redirect_protocol = "HttpsOnly"
    custom_host       = "www.example.com"
    custom_path       = "/{path}"
    custom_query_string = "{query}"
  }
}

# HTTPS listener - forward to backend
routing_rule {
  name               = "https-forward"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Https"]  # Only HTTPS
  patterns_to_match  = ["/*"]

  forwarding_configuration {
    forwarding_protocol = "MatchRequest"
    backend_pool_name   = "web-backend"
    cache_enabled       = false
  }
}
```

## Advanced Routing Configuration

### Forwarding with Custom Path

```hcl
routing_rule {
  name               = "custom-path-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/old-path/*"]

  forwarding_configuration {
    forwarding_protocol = "MatchRequest"
    backend_pool_name   = "web-backend"
    custom_forwarding_path = "/new-path/{path}"
    cache_enabled       = false
  }
}
```

### Forwarding with Query String Handling

```hcl
routing_rule {
  name               = "query-string-rule"
  frontend_endpoints = ["www-endpoint"]
  accepted_protocols = ["Http", "Https"]
  patterns_to_match  = ["/*"]

  forwarding_configuration {
    forwarding_protocol              = "MatchRequest"
    backend_pool_name                = "web-backend"
    query_parameter_strip_directive  = "StripAll"  # or "StripNone", "StripOnly"
    cache_enabled                    = true
    cache_query_parameter_strip_directive = "StripAll"
  }
}
```

**Query String Options:**
- `StripAll`: Remove all query parameters
- `StripNone`: Keep all query parameters
- `StripOnly`: Remove only specified parameters

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

## Complete Example: Multi-Path Routing

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
    name                = "web-backend"
    health_probe_name   = "http-probe"
    load_balancing_name = "lb-settings"
    # ... backend configuration ...
  }

  backend_pool {
    name                = "api-backend"
    health_probe_name   = "http-probe"
    load_balancing_name = "lb-settings"
    # ... backend configuration ...
  }

  backend_pool {
    name                = "static-backend"
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

  # Routing Rule 1: HTTP to HTTPS Redirect
  routing_rule {
    name               = "http-redirect"
    frontend_endpoints = ["www-endpoint"]
    accepted_protocols = ["Http"]
    patterns_to_match  = ["/*"]

    redirect_configuration {
      redirect_type     = "Moved"
      redirect_protocol = "HttpsOnly"
      custom_host       = "www.example.com"
      custom_path       = "/{path}"
      custom_query_string = "{query}"
    }
  }

  # Routing Rule 2: API Path
  routing_rule {
    name               = "api-rule"
    frontend_endpoints = ["www-endpoint"]
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/api/*"]

    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "api-backend"
      cache_enabled       = false
    }
  }

  # Routing Rule 3: Static Content (with caching)
  routing_rule {
    name               = "static-rule"
    frontend_endpoints = ["www-endpoint"]
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/static/*", "/images/*", "/css/*", "/js/*"]

    forwarding_configuration {
      forwarding_protocol         = "MatchRequest"
      backend_pool_name           = "static-backend"
      cache_enabled               = true
      cache_use_dynamic_compression = true
    }
  }

  # Routing Rule 4: Default (web content)
  routing_rule {
    name               = "web-rule"
    frontend_endpoints = ["www-endpoint"]
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/*"]

    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "web-backend"
      cache_enabled       = false
    }
  }
}
```

## Best Practices

1. **Specific Rules First**: Order rules from most specific to least specific
2. **HTTP to HTTPS**: Always redirect HTTP to HTTPS for security
3. **Path-Based Routing**: Use path-based routing for different content types
4. **Cache Static Content**: Enable caching for static assets
5. **Compression**: Enable compression for better performance
6. **Query String Handling**: Configure appropriate query string handling
7. **Protocol Matching**: Use specific protocols when possible

## Additional Resources

- [Front Door Routing Rule Resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor#routing_rule)
- [Front Door Routing Rules](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-routing-architecture)
- [Front Door Routing Algorithm](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-routing-methods)

