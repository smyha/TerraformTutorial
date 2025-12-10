# Front Door Backend Pools

This guide explains how to configure backend pools in Azure Front Door using Terraform.

## Overview

Backend pools contain the origin servers that serve your application content. They can include Azure services, on-premises servers, or other cloud providers.

## Basic Backend Pool

### Simple Backend Pool

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  # Backend Pool
  backend_pool {
    name                = "web-backend"
    health_probe_name   = "http-probe"
    load_balancing_name = "lb-settings"

    backend {
      host_header = "www.example.com"
      address     = "10.0.1.10"
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 50
      enabled     = true
    }
  }
}
```

## Backend Pool with Multiple Backends

### Multiple Backend Servers

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  backend_pool {
    name                = "web-backend"
    health_probe_name   = "http-probe"
    load_balancing_name = "lb-settings"

    # Backend 1
    backend {
      host_header = "www.example.com"
      address     = "10.0.1.10"
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 50
      enabled     = true
    }

    # Backend 2
    backend {
      host_header = "www.example.com"
      address     = "10.0.1.11"
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 50
      enabled     = true
    }

    # Backend 3
    backend {
      host_header = "www.example.com"
      address     = "10.0.2.10"
      http_port   = 80
      https_port  = 443
      priority    = 2
      weight      = 30
      enabled     = true
    }
  }
}
```

## Azure Backend Types

### Azure App Service Backend

```hcl
resource "azurerm_app_service" "web" {
  name                = "app-web"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id
}

resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  backend_pool {
    name                = "app-service-backend"
    health_probe_name   = "http-probe"
    load_balancing_name = "lb-settings"

    backend {
      host_header = azurerm_app_service.web.default_site_hostname
      address     = azurerm_app_service.web.default_site_hostname
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 100
      enabled     = true
    }
  }
}
```

### Azure Storage Static Website Backend

```hcl
resource "azurerm_storage_account" "static" {
  name                     = "staticwebsite"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  static_website {
    index_document = "index.html"
  }
}

resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  backend_pool {
    name                = "storage-backend"
    health_probe_name   = "http-probe"
    load_balancing_name = "lb-settings"

    backend {
      host_header = azurerm_storage_account.static.primary_web_host
      address     = azurerm_storage_account.static.primary_web_host
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 100
      enabled     = true
    }
  }
}
```

### Azure Virtual Machine Backend

```hcl
resource "azurerm_public_ip" "vm" {
  name                = "pip-vm"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  backend_pool {
    name                = "vm-backend"
    health_probe_name   = "http-probe"
    load_balancing_name = "lb-settings"

    backend {
      host_header = "www.example.com"
      address     = azurerm_public_ip.vm.ip_address
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 100
      enabled     = true
    }
  }
}
```

## On-Premises Backend

### On-Premises Server Backend

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  backend_pool {
    name                = "onprem-backend"
    health_probe_name   = "http-probe"
    load_balancing_name = "lb-settings"

    backend {
      host_header = "onprem-server.example.com"
      address     = "203.0.113.10"  # On-premises public IP
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 100
      enabled     = true
    }
  }
}
```

## Multi-Region Backend Pool

### Backends Across Multiple Regions

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  backend_pool {
    name                = "multi-region-backend"
    health_probe_name   = "http-probe"
    load_balancing_name = "lb-settings"

    # US East Backend
    backend {
      host_header = "www.example.com"
      address     = "10.0.1.10"  # US East
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 50
      enabled     = true
    }

    # Europe Backend
    backend {
      host_header = "www.example.com"
      address     = "10.1.1.10"  # Europe
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 30
      enabled     = true
    }

    # Asia Backend
    backend {
      host_header = "www.example.com"
      address     = "10.2.1.10"  # Asia
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 20
      enabled     = true
    }
  }
}
```

## Backend Configuration Parameters

### Backend Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `host_header` | string | Yes | Host header to send to backend |
| `address` | string | Yes | Backend server address (IP or FQDN) |
| `http_port` | number | Yes | HTTP port (typically 80) |
| `https_port` | number | Yes | HTTPS port (typically 443) |
| `priority` | number | No | Backend priority (lower = higher priority) |
| `weight` | number | No | Backend weight for load balancing |
| `enabled` | bool | No | Enable or disable backend |

### Priority Configuration

Priority determines failover order:
- Lower priority number = higher priority
- All traffic routes to highest priority healthy backend
- Automatic failover to next priority if primary fails

### Weight Configuration

Weight determines traffic distribution:
- Weights are relative, not percentages
- Traffic distributed proportionally based on weights
- Equal weights = equal distribution

## Complete Example

```hcl
resource "azurerm_resource_group" "fd" {
  name     = "rg-front-door"
  location = "global"
}

resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name
  friendly_name       = "Global Application Front Door"
  load_balancer_enabled = true

  # Backend Pool
  backend_pool {
    name                = "web-backend"
    health_probe_name   = "http-probe"
    load_balancing_name = "lb-settings"

    backend {
      host_header = "www.example.com"
      address     = "10.0.1.10"
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 50
      enabled     = true
    }

    backend {
      host_header = "www.example.com"
      address     = "10.0.1.11"
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 50
      enabled     = true
    }
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

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Best Practices

1. **Use Health Probes**: Always configure health probes for backend pools
2. **Configure Priorities**: Set appropriate priorities for failover scenarios
3. **Use Weights**: Configure weights for proportional distribution
4. **Enable Backends**: Ensure backends are enabled when ready
5. **Set Host Headers**: Configure appropriate host headers for backends
6. **Multi-Region**: Distribute backends across multiple regions for high availability

## Additional Resources

- [Front Door Backend Pool Resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor#backend_pool)
- [Front Door Backend Configuration](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-backend-pool)

