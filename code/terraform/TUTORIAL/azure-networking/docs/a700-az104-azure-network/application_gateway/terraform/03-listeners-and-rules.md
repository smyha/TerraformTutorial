# Implementing Application Gateway Listeners and Rules with Terraform

## Overview

Listeners receive traffic and rules determine how to route that traffic. Application Gateway supports path-based routing and multiple site hosting.

## Terraform Implementation

### Basic HTTP Listener and Rule

```hcl
resource "azurerm_application_gateway" "main" {
  # ... other configuration ...

  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "basicRule"
    rule_type                  = "Basic"
    http_listener_name         = "httpListener"
    backend_address_pool_name   = "backendPool"
    backend_http_settings_name  = "httpSettings"
  }
}
```

### HTTPS Listener with SSL Certificate

Listeners handle SSL certificates for securing your application between the user and Application Gateway.

```hcl
resource "azurerm_application_gateway" "main" {
  # ... other configuration ...

  ssl_certificate {
    name     = "sslCert"
    data     = filebase64("certificate.pfx")
    password = var.certificate_password
  }

  frontend_port {
    name = "https"
    port = 443
  }

  http_listener {
    name                           = "httpsListener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "https"
    protocol                       = "Https"
    ssl_certificate_name           = "sslCert"
  }
}
```

### Basic vs Multisite Listeners

**Basic Listener:**
- Routes based on path in URL only
- Single site configuration
- Hostname not used for routing

```hcl
http_listener {
  name                           = "basicListener"
  frontend_ip_configuration_name = "appGatewayFrontendIP"
  frontend_port_name             = "http"
  protocol                       = "Http"
  # No host_name specified = Basic listener
}
```

**Multisite Listener:**
- Routes based on hostname + path
- Multiple sites on same gateway
- Hostname used for routing

```hcl
http_listener {
  name                           = "multisiteListener"
  frontend_ip_configuration_name = "appGatewayFrontendIP"
  frontend_port_name             = "http"
  protocol                       = "Http"
  host_name                      = "contoso.com"  # Multisite listener
}
```

### Path-Based Routing

Routing rules bind listeners to backend pools and specify how to interpret hostname and path elements in the URL.

**Basic Routing Rule:**
```hcl
request_routing_rule {
  name                       = "basicRule"
  rule_type                  = "Basic"
  http_listener_name         = "httpListener"
  backend_address_pool_name   = "backendPool"
  backend_http_settings_name  = "httpSettings"
}
```

**Path-Based Routing Rule:**
```hcl
resource "azurerm_application_gateway" "main" {
  # ... other configuration ...

  # Backend pools for different paths
  backend_address_pool {
    name = "videoBackendPool"
  }

  backend_address_pool {
    name = "imageBackendPool"
  }

  backend_address_pool {
    name = "defaultBackendPool"
  }

  # URL path map for path-based routing
  url_path_map {
    name                               = "pathMap"
    default_backend_address_pool_name   = "defaultBackendPool"
    default_backend_http_settings_name  = "httpSettings"

    path_rule {
      name                       = "videoPath"
      paths                      = ["/video/*"]
      backend_address_pool_name   = "videoBackendPool"
      backend_http_settings_name = "httpSettings"
    }

    path_rule {
      name                       = "imagePath"
      paths                      = ["/images/*"]
      backend_address_pool_name   = "imageBackendPool"
      backend_http_settings_name = "httpSettings"
    }
  }

  # Request routing rule using path map
  request_routing_rule {
    name               = "pathBasedRule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "httpListener"
    url_path_map_name  = "pathMap"
  }
}
```

### HTTP Settings Configuration

HTTP settings specify backend communication configuration:

```hcl
backend_http_settings {
  name                  = "httpSettings"
  cookie_based_affinity = "Enabled"  # Session stickiness
  port                  = 80
  protocol              = "Http"     # or "Https"
  request_timeout       = 20         # Seconds
  probe_name            = "healthProbe"
  
  # Connection draining (graceful removal)
  connection_draining {
    enabled           = true
    drain_timeout_sec = 300
  }
}
```

**HTTP Settings Parameters:**
- **protocol**: HTTP or HTTPS for backend communication
- **cookie_based_affinity**: Session stickiness (Enabled/Disabled)
- **connection_draining**: Graceful server removal
- **request_timeout**: Timeout period in seconds
- **probe_name**: Associated health probe

## Additional Resources

- [Application Gateway Listeners](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-components#http-listeners)
- [Request Routing Rules](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-components#request-routing-rules)

