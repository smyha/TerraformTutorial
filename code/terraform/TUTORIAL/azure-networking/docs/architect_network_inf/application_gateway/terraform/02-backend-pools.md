# Implementing Application Gateway Backend Pools with Terraform

## Overview

Backend pools contain the servers that handle requests. Application Gateway supports VMs, VM Scale Sets, App Service, and on-premises servers.

## Terraform Implementation

### Backend Pool with VMs

```hcl
resource "azurerm_application_gateway" "main" {
  # ... other configuration ...

  backend_address_pool {
    name = "vmBackendPool"
    ip_addresses = [
      azurerm_network_interface.vm1.private_ip_address,
      azurerm_network_interface.vm2.private_ip_address
    ]
  }
}
```

### Backend Pool with VM Scale Set

```hcl
resource "azurerm_application_gateway" "main" {
  # ... other configuration ...

  backend_address_pool {
    name         = "vmssBackendPool"
    fqdns        = [azurerm_virtual_machine_scale_set.main.fqdn]
  }
}
```

### Backend Pool with App Service

```hcl
resource "azurerm_application_gateway" "main" {
  # ... other configuration ...

  backend_address_pool {
    name  = "appServiceBackendPool"
    fqdns = [azurerm_linux_web_app.main.default_hostname]
  }
}
```

### Health Probe Configuration

Health probes determine which servers are available for load balancing. If a server returns HTTP status code 200-399, it's deemed healthy.

```hcl
resource "azurerm_application_gateway" "main" {
  # ... other configuration ...

  probe {
    name                = "healthProbe"
    protocol            = "Http"
    path                = "/health"
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  backend_http_settings {
    name                  = "httpSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    probe_name            = "healthProbe"
    request_timeout       = 20
  }
}
```

**Health Probe Parameters:**
- **protocol**: Http or Https
- **path**: Health check endpoint (e.g., `/health`, `/api/health`)
- **host**: Host header for probe request
- **interval**: Seconds between probes (default: 30)
- **timeout**: Seconds to wait for response
- **unhealthy_threshold**: Failed probes before marking unhealthy
- **match.status_code**: HTTP status codes indicating health

**Default Health Probe:**
If no health probe is configured, Application Gateway creates a default probe that:
- Waits 30 seconds before marking server unavailable
- Uses root path (`/`)
- Accepts status codes 200-399

## Additional Resources

- [Application Gateway Backend Pools](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-components#backend-pools)
- [Health Probes](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-components#health-probes)

