# Terraform Implementation Guides for Azure Traffic Manager

This directory contains comprehensive guides for implementing Azure Traffic Manager services using Terraform.

## Documentation Structure

1. **[01-traffic-manager-profile.md](./01-traffic-manager-profile.md)**
   - Creating Traffic Manager profiles
   - DNS configuration
   - Basic setup

2. **[02-routing-methods.md](./02-routing-methods.md)**
   - Priority routing method
   - Weighted routing method
   - Performance routing method
   - Geographic routing method
   - Subnet routing method
   - MultiValue routing method

3. **[03-endpoints.md](./03-endpoints.md)**
   - Azure endpoints
   - External endpoints
   - Nested endpoints
   - Endpoint configuration

4. **[04-health-monitoring.md](./04-health-monitoring.md)**
   - Health probe configuration
   - Monitor configuration
   - Health check paths
   - Status code ranges

5. **[05-traffic-manager-module.md](./05-traffic-manager-module.md)**
   - Using the Traffic Manager module
   - Module configuration examples
   - Best practices

## Quick Start

### Basic Traffic Manager Profile

```hcl
# Resource Group
resource "azurerm_resource_group" "tm" {
  name     = "rg-traffic-manager"
  location = "global"
}

# Traffic Manager Profile
resource "azurerm_traffic_manager_profile" "main" {
  name                   = "tm-global-app"
  resource_group_name    = azurerm_resource_group.tm.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "global-app"
    ttl           = 60
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/health"
    interval_in_seconds           = 30
    timeout_in_seconds            = 10
    tolerated_number_of_failures = 3
  }

  tags = {
    Environment = "Production"
  }
}

# Endpoint 1 - East US
resource "azurerm_traffic_manager_endpoint" "eastus" {
  name                = "eastus-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.eastus.id
  enabled             = true
}

# Endpoint 2 - West Europe
resource "azurerm_traffic_manager_endpoint" "westeurope" {
  name                = "westeurope-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.westeurope.id
  enabled             = true
}
```

### Priority Routing Example

```hcl
resource "azurerm_traffic_manager_profile" "priority" {
  name                   = "tm-priority-app"
  resource_group_name    = azurerm_resource_group.tm.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "priority-app"
    ttl           = 60
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/health"
    interval_in_seconds           = 30
    timeout_in_seconds            = 10
    tolerated_number_of_failures = 3
  }
}

# Primary Endpoint
resource "azurerm_traffic_manager_endpoint" "primary" {
  name                = "primary-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.priority.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.primary.id
  priority            = 1
  enabled             = true
}

# Secondary Endpoint
resource "azurerm_traffic_manager_endpoint" "secondary" {
  name                = "secondary-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.priority.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.secondary.id
  priority            = 2
  enabled             = true
}
```

## Module Usage

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
    ManagedBy = "Terraform"
  }
}
```

## Additional Resources

- [Traffic Manager Module](../../../../modules/traffic-manager/README.md)
- [Azure Traffic Manager Documentation](https://learn.microsoft.com/en-us/azure/traffic-manager/)
- [Terraform Azure Traffic Manager Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/traffic_manager_profile)

