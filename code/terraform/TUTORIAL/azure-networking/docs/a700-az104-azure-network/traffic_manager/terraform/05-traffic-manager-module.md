# Using the Traffic Manager Module

This guide explains how to use the Traffic Manager Terraform module for creating and managing Azure Traffic Manager profiles.

## Module Overview

The Traffic Manager module provides a reusable way to create Traffic Manager profiles with endpoints, health monitoring, and various routing methods.

**Module Location:** `modules/traffic-manager/`

## Basic Module Usage

### Simple Performance Routing

```hcl
module "traffic_manager" {
  source = "../../modules/traffic-manager"

  resource_group_name         = azurerm_resource_group.main.name
  traffic_manager_profile_name = "tm-global-app"
  traffic_routing_method       = "Performance"

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
      target_resource_id = azurerm_public_ip.eastus.id
      enabled            = true
    },
    {
      name               = "westeurope-endpoint"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.westeurope.id
      enabled            = true
    }
  ]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Output the FQDN
output "traffic_manager_fqdn" {
  value = module.traffic_manager.traffic_manager_fqdn
}
```

## Priority Routing Example

```hcl
module "traffic_manager_priority" {
  source = "../../modules/traffic-manager"

  resource_group_name         = azurerm_resource_group.main.name
  traffic_manager_profile_name = "tm-priority-app"
  traffic_routing_method       = "Priority"

  dns_config = {
    relative_name = "priority-app"
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
      name               = "primary-endpoint"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.primary.id
      priority           = 1
      enabled            = true
    },
    {
      name               = "secondary-endpoint"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.secondary.id
      priority           = 2
      enabled            = true
    },
    {
      name               = "tertiary-endpoint"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.tertiary.id
      priority           = 3
      enabled            = true
    }
  ]
}
```

## Weighted Routing Example

```hcl
module "traffic_manager_weighted" {
  source = "../../modules/traffic-manager"

  resource_group_name         = azurerm_resource_group.main.name
  traffic_manager_profile_name = "tm-weighted-app"
  traffic_routing_method       = "Weighted"

  dns_config = {
    relative_name = "weighted-app"
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
      name               = "endpoint-1"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.endpoint1.id
      weight             = 50
      enabled            = true
    },
    {
      name               = "endpoint-2"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.endpoint2.id
      weight             = 30
      enabled            = true
    },
    {
      name               = "endpoint-3"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.endpoint3.id
      weight             = 20
      enabled            = true
    }
  ]
}
```

## Geographic Routing Example

```hcl
module "traffic_manager_geographic" {
  source = "../../modules/traffic-manager"

  resource_group_name         = azurerm_resource_group.main.name
  traffic_manager_profile_name = "tm-geographic-app"
  traffic_routing_method       = "Geographic"

  dns_config = {
    relative_name = "geographic-app"
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
      name               = "eu-endpoint"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.eu.id
      geo_mappings       = ["DE", "FR", "GB", "IT", "ES"]
      enabled            = true
    },
    {
      name               = "us-endpoint"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.us.id
      geo_mappings       = ["US", "CA", "MX"]
      enabled            = true
    },
    {
      name               = "asia-endpoint"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.asia.id
      geo_mappings       = ["JP", "CN", "IN", "KR"]
      enabled            = true
    }
  ]
}
```

## External Endpoints Example

```hcl
module "traffic_manager_hybrid" {
  source = "../../modules/traffic-manager"

  resource_group_name         = azurerm_resource_group.main.name
  traffic_manager_profile_name = "tm-hybrid-app"
  traffic_routing_method       = "Performance"

  dns_config = {
    relative_name = "hybrid-app"
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
      name               = "azure-endpoint"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.azure.id
      enabled            = true
    },
    {
      name    = "onprem-endpoint"
      type    = "externalEndpoints"
      target  = "onprem-server.example.com"
      enabled = true
    },
    {
      name    = "aws-endpoint"
      type    = "externalEndpoints"
      target  = "aws-elb.example.com"
      enabled = true
    }
  ]
}
```

## Advanced Configuration

### Custom Headers

```hcl
module "traffic_manager_advanced" {
  source = "../../modules/traffic-manager"

  resource_group_name         = azurerm_resource_group.main.name
  traffic_manager_profile_name = "tm-advanced-app"
  traffic_routing_method       = "Performance"

  dns_config = {
    relative_name = "advanced-app"
    ttl           = 60
  }

  monitor_config = {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/health"
    interval_in_seconds           = 30
    timeout_in_seconds            = 10
    tolerated_number_of_failures = 3
    expected_status_code_ranges   = ["200-299", "301-302"]
  }

  endpoints = [
    {
      name               = "endpoint-1"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.endpoint1.id
      custom_headers = [
        {
          name  = "X-Custom-Header"
          value = "CustomValue"
        },
        {
          name  = "X-API-Key"
          value = "SecretKey123"
        }
      ]
      enabled = true
    }
  ]
}
```

### Subnet Routing

```hcl
module "traffic_manager_subnet" {
  source = "../../modules/traffic-manager"

  resource_group_name         = azurerm_resource_group.main.name
  traffic_manager_profile_name = "tm-subnet-app"
  traffic_routing_method       = "Subnet"

  dns_config = {
    relative_name = "subnet-app"
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
      name               = "internal-endpoint"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.internal.id
      subnet_ids         = ["10.0.0.0/24", "10.0.1.0/24"]
      enabled            = true
    },
    {
      name               = "external-endpoint"
      type               = "azureEndpoints"
      target_resource_id = azurerm_public_ip.external.id
      # No subnet_ids = default endpoint
      enabled            = true
    }
  ]
}
```

## Module Outputs

The module provides the following outputs:

```hcl
# Get Traffic Manager FQDN
output "traffic_manager_fqdn" {
  value = module.traffic_manager.traffic_manager_fqdn
}

# Get Traffic Manager Profile ID
output "traffic_manager_profile_id" {
  value = module.traffic_manager.traffic_manager_profile_id
}

# Get Traffic Manager Profile Name
output "traffic_manager_profile_name" {
  value = module.traffic_manager.traffic_manager_profile_name
}

# Get Endpoint IDs
output "endpoint_ids" {
  value = module.traffic_manager.endpoint_ids
}
```

## Using Module Outputs

### Create CNAME Record

```hcl
# Traffic Manager Module
module "traffic_manager" {
  source = "../../modules/traffic-manager"
  # ... configuration ...
}

# DNS Zone
resource "azurerm_dns_zone" "main" {
  name                = "example.com"
  resource_group_name = azurerm_resource_group.main.name
}

# CNAME Record pointing to Traffic Manager
resource "azurerm_dns_cname_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  record              = module.traffic_manager.traffic_manager_fqdn
}
```

## Best Practices

1. **Use Modules**: Use the module for consistency and reusability
2. **Configure Health Probes**: Always configure appropriate health monitoring
3. **Set Short TTLs**: Use 60 seconds TTL for faster failover
4. **Tag Resources**: Add meaningful tags for organization
5. **Use Variables**: Parameterize configuration for different environments
6. **Monitor Outputs**: Use module outputs for integration with other resources

## Module Variables Reference

### Required Variables

- `resource_group_name`: Name of the resource group
- `traffic_manager_profile_name`: Name of the Traffic Manager profile
- `dns_config`: DNS configuration (relative_name, ttl)
- `monitor_config`: Health monitor configuration

### Optional Variables

- `traffic_routing_method`: Routing method (default: "Performance")
- `endpoints`: List of endpoints (default: [])
- `tags`: Map of tags (default: {})
- `location`: Location (default: "global")

## Additional Resources

- [Traffic Manager Module](../../../../modules/traffic-manager/README.md)
- [Traffic Manager Module Source](../../../../modules/traffic-manager/)
- [Azure Traffic Manager Documentation](https://learn.microsoft.com/en-us/azure/traffic-manager/)

