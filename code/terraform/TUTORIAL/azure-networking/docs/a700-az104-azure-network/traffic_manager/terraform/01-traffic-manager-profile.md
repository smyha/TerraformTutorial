# Creating Traffic Manager Profiles with Terraform

This guide explains how to create Azure Traffic Manager profiles using Terraform.

## Overview

Azure Traffic Manager is a DNS-based traffic load balancer that distributes traffic to endpoints based on routing methods. A Traffic Manager profile is the main resource that contains the configuration for routing and monitoring.

## Basic Traffic Manager Profile

### Minimal Configuration

```hcl
resource "azurerm_resource_group" "tm" {
  name     = "rg-traffic-manager"
  location = "global"  # Traffic Manager is global, not region-specific
}

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
```

## DNS Configuration

The `dns_config` block configures the DNS settings for the Traffic Manager profile.

### DNS Configuration Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `relative_name` | string | Yes | The relative DNS name. Creates FQDN: `{relative_name}.trafficmanager.net` |
| `ttl` | number | Yes | Time-to-live (TTL) in seconds. Recommended: 60 seconds for fast failover |

### DNS Configuration Example

```hcl
dns_config {
  relative_name = "my-global-app"
  ttl           = 60
}

# Creates FQDN: my-global-app.trafficmanager.net
```

**Important Notes:**
- The `relative_name` must be unique within the `.trafficmanager.net` domain
- Shorter TTL values (60 seconds) enable faster failover
- Longer TTL values reduce DNS query load but slow failover

## Monitor Configuration

The `monitor_config` block configures health monitoring for endpoints.

### Monitor Configuration Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `protocol` | string | Yes | Protocol: `HTTP`, `HTTPS`, or `TCP` |
| `port` | number | Yes | Port number to probe |
| `path` | string | No | Path for HTTP/HTTPS probes (default: `/`) |
| `interval_in_seconds` | number | Yes | Probe interval in seconds (default: 30) |
| `timeout_in_seconds` | number | Yes | Probe timeout in seconds (default: 10) |
| `tolerated_number_of_failures` | number | Yes | Failures before marking unhealthy (default: 3) |
| `expected_status_code_ranges` | list(string) | No | Expected HTTP status code ranges (e.g., `["200-299"]`) |

### Monitor Configuration Examples

#### HTTP Health Probe

```hcl
monitor_config {
  protocol                     = "HTTP"
  port                         = 80
  path                         = "/health"
  interval_in_seconds           = 30
  timeout_in_seconds            = 10
  tolerated_number_of_failures = 3
  expected_status_code_ranges   = ["200-299"]
}
```

#### HTTPS Health Probe

```hcl
monitor_config {
  protocol                     = "HTTPS"
  port                         = 443
  path                         = "/api/health"
  interval_in_seconds           = 30
  timeout_in_seconds            = 10
  tolerated_number_of_failures = 3
  expected_status_code_ranges   = ["200-299", "301-302"]
}
```

#### TCP Health Probe

```hcl
monitor_config {
  protocol                     = "TCP"
  port                         = 3389
  interval_in_seconds           = 30
  timeout_in_seconds            = 10
  tolerated_number_of_failures = 3
  # Note: path and expected_status_code_ranges not used for TCP
}
```

## Complete Example

```hcl
# Resource Group
resource "azurerm_resource_group" "tm" {
  name     = "rg-traffic-manager"
  location = "global"
}

# Traffic Manager Profile
resource "azurerm_traffic_manager_profile" "main" {
  name                   = "tm-global-webapp"
  resource_group_name    = azurerm_resource_group.tm.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "global-webapp"
    ttl           = 60
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/health"
    interval_in_seconds           = 30
    timeout_in_seconds            = 10
    tolerated_number_of_failures = 3
    expected_status_code_ranges   = ["200-299"]
  }

  tags = {
    Environment = "Production"
    Application = "Global Web App"
    ManagedBy   = "Terraform"
  }
}

# Output the FQDN
output "traffic_manager_fqdn" {
  description = "The FQDN of the Traffic Manager profile"
  value       = azurerm_traffic_manager_profile.main.fqdn
}

# Output: global-webapp.trafficmanager.net
```

## Traffic Routing Methods

The `traffic_routing_method` parameter determines how Traffic Manager routes traffic:

- **Priority**: Failover routing (primary → secondary)
- **Weighted**: Proportional distribution based on weights
- **Performance**: Route to lowest latency endpoint
- **Geographic**: Route based on user location
- **Subnet**: Route based on source IP subnet
- **MultiValue**: Return multiple healthy endpoints

See [02-routing-methods.md](./02-routing-methods.md) for detailed examples of each routing method.

## Best Practices

1. **Use Short TTLs**: Set TTL to 60 seconds for faster failover
2. **Configure Health Probes**: Always configure appropriate health probes
3. **Use HTTPS for Probes**: Use HTTPS when possible for secure health checks
4. **Set Appropriate Intervals**: Balance between responsiveness and probe load
5. **Monitor Health Status**: Use Azure Monitor to track endpoint health

## Additional Resources

- [Traffic Manager Profile Resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/traffic_manager_profile)
- [Traffic Manager DNS Configuration](https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-how-it-works)
- [Traffic Manager Health Monitoring](https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-monitoring)

