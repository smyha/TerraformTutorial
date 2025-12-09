# Traffic Manager Endpoints

This guide explains how to configure different types of endpoints in Azure Traffic Manager using Terraform.

## Overview

Traffic Manager endpoints are the destinations that traffic is routed to. Traffic Manager supports three types of endpoints:

1. **Azure Endpoints**: Azure resources (Public IPs, App Services, etc.)
2. **External Endpoints**: External services (on-premises, other clouds)
3. **Nested Endpoints**: Other Traffic Manager profiles

## Azure Endpoints

Azure endpoints point to Azure resources like Public IPs, App Services, or other Azure services.

### Azure Endpoint with Public IP

```hcl
# Public IP for endpoint
resource "azurerm_public_ip" "eastus" {
  name                = "pip-eastus"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.tm.name
  allocation_method   = "Static"
  sku                 = "Standard"
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
}

# Azure Endpoint
resource "azurerm_traffic_manager_endpoint" "eastus" {
  name                = "eastus-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.eastus.id
  enabled             = true
}
```

### Azure Endpoint with App Service

```hcl
# App Service
resource "azurerm_app_service" "eastus" {
  name                = "app-eastus"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.tm.name
  app_service_plan_id = azurerm_app_service_plan.eastus.id
}

# Azure Endpoint pointing to App Service
resource "azurerm_traffic_manager_endpoint" "app_eastus" {
  name                = "app-eastus-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_app_service.eastus.id
  enabled             = true
}
```

### Azure Endpoint with Load Balancer

```hcl
# Load Balancer
resource "azurerm_lb" "eastus" {
  name                = "lb-eastus"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.tm.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.eastus.id
  }
}

# Azure Endpoint pointing to Load Balancer
resource "azurerm_traffic_manager_endpoint" "lb_eastus" {
  name                = "lb-eastus-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_lb.eastus.id
  enabled             = true
}
```

## External Endpoints

External endpoints point to services outside Azure, such as on-premises datacenters or other cloud providers.

### External Endpoint Configuration

```hcl
# External Endpoint (On-Premises)
resource "azurerm_traffic_manager_endpoint" "onprem" {
  name                = "onprem-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "externalEndpoints"
  target              = "onprem-server.example.com"  # FQDN or IP
  enabled             = true
}

# External Endpoint (AWS)
resource "azurerm_traffic_manager_endpoint" "aws" {
  name                = "aws-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "externalEndpoints"
  target              = "aws-elb-123456789.us-east-1.elb.amazonaws.com"
  enabled             = true
}

# External Endpoint (Google Cloud)
resource "azurerm_traffic_manager_endpoint" "gcp" {
  name                = "gcp-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "externalEndpoints"
  target              = "gcp-lb-ip.example.com"
  enabled             = true
}
```

**Key Points:**
- Use `target` instead of `target_resource_id` for external endpoints
- Target can be FQDN or IP address
- Useful for hybrid and multi-cloud scenarios

## Nested Endpoints

Nested endpoints point to other Traffic Manager profiles, enabling hierarchical routing.

### Nested Endpoint Configuration

```hcl
# Parent Traffic Manager Profile
resource "azurerm_traffic_manager_profile" "parent" {
  name                   = "tm-parent"
  resource_group_name    = azurerm_resource_group.tm.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "parent-app"
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

# Child Traffic Manager Profile (Regional)
resource "azurerm_traffic_manager_profile" "child_eastus" {
  name                   = "tm-child-eastus"
  resource_group_name    = azurerm_resource_group.tm.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "child-eastus"
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

# Endpoints in child profile
resource "azurerm_traffic_manager_endpoint" "child_eastus_1" {
  name                = "child-eastus-1"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.child_eastus.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.eastus1.id
  weight              = 50
  enabled             = true
}

resource "azurerm_traffic_manager_endpoint" "child_eastus_2" {
  name                = "child-eastus-2"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.child_eastus.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.eastus2.id
  weight              = 50
  enabled             = true
}

# Nested Endpoint (Child profile as endpoint in parent)
resource "azurerm_traffic_manager_endpoint" "nested_eastus" {
  name                = "nested-eastus"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.parent.name
  type                = "nestedEndpoints"
  target_resource_id  = azurerm_traffic_manager_profile.child_eastus.id
  minimum_child_endpoints = 1  # Minimum healthy endpoints in child
  enabled             = true
}
```

**Key Points:**
- Nested endpoints enable hierarchical routing
- Parent profile routes to child profiles
- Child profiles can use different routing methods
- `minimum_child_endpoints` specifies minimum healthy endpoints in child

## Endpoint Configuration Options

### Priority Configuration

```hcl
resource "azurerm_traffic_manager_endpoint" "priority" {
  name                = "priority-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.main.id
  priority            = 1  # For Priority routing method
  enabled             = true
}
```

### Weight Configuration

```hcl
resource "azurerm_traffic_manager_endpoint" "weighted" {
  name                = "weighted-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.main.id
  weight              = 50  # For Weighted routing method
  enabled             = true
}
```

### Geographic Mapping

```hcl
resource "azurerm_traffic_manager_endpoint" "geographic" {
  name                = "geographic-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.main.id
  geo_mappings        = [
    "US",  # United States
    "CA",  # Canada
    "MX",  # Mexico
  ]
  enabled             = true
}
```

### Subnet Mapping

```hcl
resource "azurerm_traffic_manager_endpoint" "subnet" {
  name                = "subnet-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.main.id
  subnet_ids          = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "192.168.0.0/16"
  ]
  enabled             = true
}
```

### Custom Headers

```hcl
resource "azurerm_traffic_manager_endpoint" "custom_headers" {
  name                = "custom-headers-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.main.id
  
  custom_header {
    name  = "X-Custom-Header"
    value = "CustomValue"
  }
  
  custom_header {
    name  = "X-API-Key"
    value = "SecretKey123"
  }
  
  enabled = true
}
```

### Disabled Endpoint

```hcl
resource "azurerm_traffic_manager_endpoint" "disabled" {
  name                = "disabled-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.main.id
  enabled             = false  # Endpoint disabled, no traffic routed
}
```

## Complete Example: Multi-Type Endpoints

```hcl
resource "azurerm_traffic_manager_profile" "hybrid" {
  name                   = "tm-hybrid-app"
  resource_group_name    = azurerm_resource_group.tm.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "hybrid-app"
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

# Azure Endpoint
resource "azurerm_traffic_manager_endpoint" "azure" {
  name                = "azure-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.hybrid.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.azure.id
  enabled             = true
}

# External Endpoint (On-Premises)
resource "azurerm_traffic_manager_endpoint" "onprem" {
  name                = "onprem-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.hybrid.name
  type                = "externalEndpoints"
  target              = "onprem-server.example.com"
  enabled             = true
}

# External Endpoint (AWS)
resource "azurerm_traffic_manager_endpoint" "aws" {
  name                = "aws-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.hybrid.name
  type                = "externalEndpoints"
  target              = "aws-elb.example.com"
  enabled             = true
}
```

## Best Practices

1. **Use Appropriate Endpoint Types**: Choose based on your architecture
2. **Enable/Disable Endpoints**: Use `enabled` to control traffic routing
3. **Configure Custom Headers**: Add headers for authentication or routing
4. **Test Endpoint Health**: Verify health probes work correctly
5. **Monitor Endpoint Status**: Use Azure Monitor to track endpoint health

## Additional Resources

- [Traffic Manager Endpoint Resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/traffic_manager_endpoint)
- [Traffic Manager Endpoint Types](https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-endpoint-types)
- [Traffic Manager Nested Profiles](https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-nested-profiles)

