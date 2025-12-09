# Traffic Manager Routing Methods

This guide explains how to configure different traffic routing methods in Azure Traffic Manager using Terraform.

## Overview

Traffic Manager supports six routing methods that determine how traffic is distributed to endpoints:

1. **Priority**: Failover routing
2. **Weighted**: Proportional distribution
3. **Performance**: Latency-based routing
4. **Geographic**: Location-based routing
5. **Subnet**: IP subnet-based routing
6. **MultiValue**: Multiple endpoint responses

## Priority Routing Method

Priority routing provides automatic failover from primary to backup endpoints.

### Priority Routing Configuration

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

# Primary Endpoint (Priority 1)
resource "azurerm_traffic_manager_endpoint" "primary" {
  name                = "primary-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.priority.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.primary.id
  priority            = 1  # Highest priority
  enabled             = true
}

# Secondary Endpoint (Priority 2)
resource "azurerm_traffic_manager_endpoint" "secondary" {
  name                = "secondary-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.priority.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.secondary.id
  priority            = 2  # Backup
  enabled             = true
}

# Tertiary Endpoint (Priority 3)
resource "azurerm_traffic_manager_endpoint" "tertiary" {
  name                = "tertiary-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.priority.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.tertiary.id
  priority            = 3  # Last resort
  enabled             = true
}
```

**Key Points:**
- Lower priority number = higher priority
- All traffic routes to the highest priority healthy endpoint
- Automatic failover to next priority if primary fails

## Weighted Routing Method

Weighted routing distributes traffic proportionally based on configured weights.

### Weighted Routing Configuration

```hcl
resource "azurerm_traffic_manager_profile" "weighted" {
  name                   = "tm-weighted-app"
  resource_group_name    = azurerm_resource_group.tm.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "weighted-app"
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

# Endpoint 1 - 50% of traffic
resource "azurerm_traffic_manager_endpoint" "endpoint1" {
  name                = "endpoint-1"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.weighted.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.endpoint1.id
  weight              = 50  # 50% of traffic
  enabled             = true
}

# Endpoint 2 - 30% of traffic
resource "azurerm_traffic_manager_endpoint" "endpoint2" {
  name                = "endpoint-2"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.weighted.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.endpoint2.id
  weight              = 30  # 30% of traffic
  enabled             = true
}

# Endpoint 3 - 20% of traffic
resource "azurerm_traffic_manager_endpoint" "endpoint3" {
  name                = "endpoint-3"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.weighted.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.endpoint3.id
  weight              = 20  # 20% of traffic
  enabled             = true
}
```

**Key Points:**
- Weights are relative, not percentages
- Traffic distributed proportionally based on weights
- Equal weights = equal distribution
- Useful for gradual migrations and A/B testing

### Equal Weight Distribution

```hcl
# All endpoints with equal weight (33.33% each)
resource "azurerm_traffic_manager_endpoint" "equal1" {
  name                = "equal-endpoint-1"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.weighted.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.equal1.id
  weight              = 1  # Equal weight
  enabled             = true
}

resource "azurerm_traffic_manager_endpoint" "equal2" {
  name                = "equal-endpoint-2"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.weighted.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.equal2.id
  weight              = 1  # Equal weight
  enabled             = true
}

resource "azurerm_traffic_manager_endpoint" "equal3" {
  name                = "equal-endpoint-3"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.weighted.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.equal3.id
  weight              = 1  # Equal weight
  enabled             = true
}
```

## Performance Routing Method

Performance routing routes traffic to the endpoint with the lowest latency.

### Performance Routing Configuration

```hcl
resource "azurerm_traffic_manager_profile" "performance" {
  name                   = "tm-performance-app"
  resource_group_name    = azurerm_resource_group.tm.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "performance-app"
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

# East US Endpoint (best for North America)
resource "azurerm_traffic_manager_endpoint" "eastus" {
  name                = "eastus-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.performance.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.eastus.id
  enabled             = true
}

# West Europe Endpoint (best for Europe)
resource "azurerm_traffic_manager_endpoint" "westeurope" {
  name                = "westeurope-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.performance.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.westeurope.id
  enabled             = true
}

# Southeast Asia Endpoint (best for Asia)
resource "azurerm_traffic_manager_endpoint" "southeastasia" {
  name                = "southeastasia-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.performance.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.southeastasia.id
  enabled             = true
}
```

**Key Points:**
- Traffic Manager maintains a latency table
- Routes to endpoint with lowest latency for user's location
- Automatic selection based on network performance
- No priority or weight configuration needed

## Geographic Routing Method

Geographic routing routes traffic based on the user's geographic location.

### Geographic Routing Configuration

```hcl
resource "azurerm_traffic_manager_profile" "geographic" {
  name                   = "tm-geographic-app"
  resource_group_name    = azurerm_resource_group.tm.name
  traffic_routing_method = "Geographic"

  dns_config {
    relative_name = "geographic-app"
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

# EU Endpoint (serves European countries)
resource "azurerm_traffic_manager_endpoint" "eu" {
  name                = "eu-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.geographic.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.eu.id
  geo_mappings        = [
    "DE",  # Germany
    "FR",  # France
    "GB",  # United Kingdom
    "IT",  # Italy
    "ES",  # Spain
    # ... more EU countries
  ]
  enabled             = true
}

# US Endpoint (serves United States)
resource "azurerm_traffic_manager_endpoint" "us" {
  name                = "us-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.geographic.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.us.id
  geo_mappings        = [
    "US",  # United States
    "CA",  # Canada
  ]
  enabled             = true
}

# Asia Endpoint (serves Asian countries)
resource "azurerm_traffic_manager_endpoint" "asia" {
  name                = "asia-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.geographic.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.asia.id
  geo_mappings        = [
    "JP",  # Japan
    "CN",  # China
    "IN",  # India
    "KR",  # South Korea
    # ... more Asian countries
  ]
  enabled             = true
}
```

**Key Points:**
- Use ISO 3166-1 alpha-2 country codes
- Each endpoint can serve multiple countries
- Useful for data residency and compliance
- Deterministic routing (same location = same endpoint)

## Subnet Routing Method

Subnet routing routes traffic based on the source IP subnet.

### Subnet Routing Configuration

```hcl
resource "azurerm_traffic_manager_profile" "subnet" {
  name                   = "tm-subnet-app"
  resource_group_name    = azurerm_resource_group.tm.name
  traffic_routing_method = "Subnet"

  dns_config {
    relative_name = "subnet-app"
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

# Internal Endpoint (for internal subnets)
resource "azurerm_traffic_manager_endpoint" "internal" {
  name                = "internal-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.subnet.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.internal.id
  subnet_ids          = [
    "10.0.0.0/24",  # Internal subnet 1
    "10.0.1.0/24",  # Internal subnet 2
    "192.168.0.0/16"  # Internal subnet range
  ]
  enabled             = true
}

# External Endpoint (for all other traffic)
resource "azurerm_traffic_manager_endpoint" "external" {
  name                = "external-endpoint"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.subnet.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.external.id
  # No subnet_ids = default endpoint for unmatched subnets
  enabled             = true
}
```

**Key Points:**
- Routes based on source IP subnet
- Useful for internal vs external routing
- Supports CIDR notation
- Endpoint without subnet_ids acts as default

## MultiValue Routing Method

MultiValue routing returns multiple healthy endpoints in DNS responses.

### MultiValue Routing Configuration

```hcl
resource "azurerm_traffic_manager_profile" "multivalue" {
  name                   = "tm-multivalue-app"
  resource_group_name    = azurerm_resource_group.tm.name
  traffic_routing_method = "MultiValue"

  dns_config {
    relative_name = "multivalue-app"
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

# Multiple endpoints (all returned if healthy)
resource "azurerm_traffic_manager_endpoint" "multivalue1" {
  name                = "multivalue-endpoint-1"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.multivalue.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.multivalue1.id
  enabled             = true
}

resource "azurerm_traffic_manager_endpoint" "multivalue2" {
  name                = "multivalue-endpoint-2"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.multivalue.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.multivalue2.id
  enabled             = true
}

resource "azurerm_traffic_manager_endpoint" "multivalue3" {
  name                = "multivalue-endpoint-3"
  resource_group_name = azurerm_resource_group.tm.name
  profile_name        = azurerm_traffic_manager_profile.multivalue.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.multivalue3.id
  enabled             = true
}
```

**Key Points:**
- Returns up to 8 healthy endpoints in DNS response
- Client can choose which endpoint to use
- Useful for client-side load balancing
- Only healthy endpoints are returned

## Routing Method Comparison

| Method | Configuration | Use Case |
|--------|--------------|----------|
| **Priority** | `priority` attribute | Disaster recovery, failover |
| **Weighted** | `weight` attribute | Gradual migration, A/B testing |
| **Performance** | No special config | Global apps, low latency |
| **Geographic** | `geo_mappings` attribute | Data residency, compliance |
| **Subnet** | `subnet_ids` attribute | Internal vs external routing |
| **MultiValue** | No special config | Client-side load balancing |

## Best Practices

1. **Choose the Right Method**: Select based on your use case
2. **Configure Health Probes**: Essential for all routing methods
3. **Test Failover**: Verify failover behavior for Priority routing
4. **Monitor Performance**: Track latency for Performance routing
5. **Update Geo Mappings**: Keep geographic mappings current

## Additional Resources

- [Traffic Manager Routing Methods](https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-routing-methods)
- [Traffic Manager Endpoint Resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/traffic_manager_endpoint)

