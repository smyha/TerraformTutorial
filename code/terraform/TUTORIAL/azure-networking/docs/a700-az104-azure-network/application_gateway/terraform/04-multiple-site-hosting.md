# Implementing Multiple Site Hosting with Terraform

## Overview

Multiple site hosting allows you to configure more than one web application on the same Application Gateway instance using different hostnames.

## Terraform Implementation

### Multiple Site Configuration

```hcl
resource "azurerm_application_gateway" "main" {
  # ... other configuration ...

  # Backend pools for different sites
  backend_address_pool {
    name = "contosoBackendPool"
  }

  backend_address_pool {
    name = "fabrikamBackendPool"
  }

  # Listeners for different hostnames
  http_listener {
    name                           = "contosoListener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "http"
    protocol                       = "Http"
    host_name                      = "contoso.com"
  }

  http_listener {
    name                           = "fabrikamListener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "http"
    protocol                       = "Http"
    host_name                      = "fabrikam.com"
  }

  # Routing rules for each site
  request_routing_rule {
    name                       = "contosoRule"
    rule_type                  = "Basic"
    http_listener_name         = "contosoListener"
    backend_address_pool_name   = "contosoBackendPool"
    backend_http_settings_name  = "httpSettings"
  }

  request_routing_rule {
    name                       = "fabrikamRule"
    rule_type                  = "Basic"
    http_listener_name         = "fabrikamListener"
    backend_address_pool_name   = "fabrikamBackendPool"
    backend_http_settings_name  = "httpSettings"
  }
}
```

## Additional Resources

- [Multiple Site Hosting](https://learn.microsoft.com/en-us/azure/application-gateway/multiple-site-overview)

