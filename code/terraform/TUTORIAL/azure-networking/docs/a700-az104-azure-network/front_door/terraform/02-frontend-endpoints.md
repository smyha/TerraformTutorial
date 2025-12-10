# Front Door Frontend Endpoints

This guide explains how to configure frontend endpoints in Azure Front Door using Terraform.

## Overview

Frontend endpoints are the entry points for client requests in Azure Front Door. They define the hostname and domain configuration that clients use to access your application.

## Basic Frontend Endpoint

### Default Frontend Endpoint

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  # Frontend Endpoint (Default)
  frontend_endpoint {
    name      = "default-endpoint"
    host_name = "fd-global-app.azurefd.net"  # Default Front Door hostname
  }
}
```

## Custom Domain Frontend Endpoint

### Custom Domain Configuration

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  # Frontend Endpoint with Custom Domain
  frontend_endpoint {
    name      = "www-endpoint"
    host_name = "www.example.com"
  }
}
```

### DNS Configuration

After creating the Front Door with a custom domain, you need to configure DNS:

```hcl
# Get the Front Door CNAME
output "front_door_cname" {
  value = azurerm_frontdoor.main.cname
}

# Create CNAME record in DNS
# www.example.com CNAME fd-global-app.azurefd.net
```

## SSL/TLS Certificate Configuration

### Managed Certificate (Front Door Managed)

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  frontend_endpoint {
    name                                    = "www-endpoint"
    host_name                               = "www.example.com"
    custom_https_provisioning_enabled       = true
    custom_https_configuration {
      certificate_source = "FrontDoor"
    }
  }
}
```

### Custom Certificate

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  frontend_endpoint {
    name                                    = "www-endpoint"
    host_name                               = "www.example.com"
    custom_https_provisioning_enabled       = true
    custom_https_configuration {
      certificate_source                    = "AzureKeyVault"
      azure_key_vault_certificate_secret_name = "my-certificate"
      azure_key_vault_certificate_secret_version = "latest"
      azure_key_vault_certificate_vault_id  = azurerm_key_vault.main.id
    }
  }
}
```

## Session Affinity Configuration

### Enable Session Affinity

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  frontend_endpoint {
    name                      = "www-endpoint"
    host_name                 = "www.example.com"
    session_affinity_enabled  = true
    session_affinity_ttl_seconds = 3600  # 1 hour
  }
}
```

**Session Affinity Parameters:**
- `session_affinity_enabled`: Enable session affinity (cookie-based)
- `session_affinity_ttl_seconds`: Time-to-live for session affinity cookie

## WAF Policy Association

### Associate WAF Policy (Premium Tier)

```hcl
# WAF Policy
resource "azurerm_frontdoor_firewall_policy" "main" {
  name                = "waf-policy"
  resource_group_name = azurerm_resource_group.fd.name
  enabled             = true
  mode                = "Prevention"
}

# Frontend Endpoint with WAF
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  frontend_endpoint {
    name                                    = "www-endpoint"
    host_name                               = "www.example.com"
    web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.main.id
  }
}
```

## Multiple Frontend Endpoints

### Multiple Domains Configuration

```hcl
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name

  # Frontend Endpoint 1
  frontend_endpoint {
    name      = "www-endpoint"
    host_name = "www.example.com"
  }

  # Frontend Endpoint 2
  frontend_endpoint {
    name      = "api-endpoint"
    host_name = "api.example.com"
  }

  # Frontend Endpoint 3
  frontend_endpoint {
    name      = "cdn-endpoint"
    host_name = "cdn.example.com"
  }
}
```

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

  # Frontend Endpoint with Custom Domain and HTTPS
  frontend_endpoint {
    name                                    = "www-endpoint"
    host_name                               = "www.example.com"
    session_affinity_enabled                = false
    custom_https_provisioning_enabled       = true
    custom_https_configuration {
      certificate_source = "FrontDoor"
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Output Front Door CNAME for DNS configuration
output "front_door_cname" {
  description = "CNAME to configure in DNS"
  value       = azurerm_frontdoor.main.cname
}

# Output Front Door hostname
output "front_door_hostname" {
  description = "Front Door hostname"
  value       = azurerm_frontdoor.main.cname
}
```

## Best Practices

1. **Use Custom Domains**: Use custom domains for production applications
2. **Enable HTTPS**: Always enable HTTPS for custom domains
3. **Use Managed Certificates**: Use Front Door managed certificates for simplicity
4. **Configure DNS**: Properly configure CNAME records in DNS
5. **Session Affinity**: Enable only when required for stateful applications
6. **WAF Association**: Associate WAF policies for Premium tier applications

## Additional Resources

- [Front Door Frontend Endpoint Resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor#frontend_endpoint)
- [Front Door Custom Domain Configuration](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-custom-domain)
- [Front Door SSL/TLS Configuration](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-custom-domain-https)

