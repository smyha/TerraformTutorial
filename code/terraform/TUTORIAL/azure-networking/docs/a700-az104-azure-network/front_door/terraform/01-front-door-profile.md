# Creating Azure Front Door Profiles with Terraform

This guide explains how to create Azure Front Door profiles using Terraform.

## Overview

Azure Front Door is Microsoft's modern cloud CDN that provides fast, reliable, and secure access between users and applications. A Front Door profile is the top-level resource that contains all Front Door configurations.

## Basic Front Door Profile

### Minimal Configuration

```hcl
resource "azurerm_resource_group" "fd" {
  name     = "rg-front-door"
  location = "global"  # Front Door is global, not region-specific
}

resource "azurerm_frontdoor" "main" {
  name                = "fd-global-app"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name
  friendly_name       = "Global Application Front Door"
  load_balancer_enabled = true
}
```

## Front Door Configuration Parameters

### Basic Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Name of the Front Door (must be globally unique) |
| `location` | string | Yes | Azure region (typically "global" for Front Door) |
| `resource_group_name` | string | Yes | Name of the resource group |
| `friendly_name` | string | No | Friendly name for the Front Door profile |
| `load_balancer_enabled` | bool | No | Enable load balancing (default: true) |

### Front Door Name Requirements

- Must be globally unique across all Azure Front Door instances
- Can contain letters, numbers, and hyphens
- Must start with a letter or number
- Must be between 5 and 64 characters

## Complete Example

```hcl
# Resource Group
resource "azurerm_resource_group" "fd" {
  name     = "rg-front-door"
  location = "global"
}

# Front Door Profile
resource "azurerm_frontdoor" "main" {
  name                = "fd-global-webapp"
  location            = "global"
  resource_group_name = azurerm_resource_group.fd.name
  friendly_name       = "Global Web Application Front Door"
  load_balancer_enabled = true

  tags = {
    Environment = "Production"
    Application = "Global Web App"
    ManagedBy   = "Terraform"
  }
}

# Output the Front Door hostname
output "front_door_hostname" {
  description = "The hostname of the Front Door"
  value       = azurerm_frontdoor.main.cname
}

# Output: fd-global-webapp.azurefd.net
```

## Front Door Tiers

Azure Front Door supports two tiers: Standard and Premium. The tier determines available features and capabilities.

### Standard Tier

Standard tier is content-delivery optimized, providing:
- Static and dynamic content acceleration
- Global load balancing
- SSL offload
- Domain and certificate management
- Enhanced traffic analytics
- Basic security capabilities

### Premium Tier

Premium tier is security optimized, providing all Standard features plus:
- Extensive WAF capabilities
- BOT protection
- Private Link support
- Microsoft Threat Intelligence integration
- Advanced security analytics

**Note:** Tier selection is typically done at the Azure Front Door Standard/Premium resource level (`azurerm_cdn_frontdoor_profile`), not the classic Front Door resource.

## Best Practices

1. **Use Descriptive Names**: Choose meaningful names for Front Door profiles
2. **Enable Load Balancing**: Keep `load_balancer_enabled` set to true for high availability
3. **Use Tags**: Add meaningful tags for organization and management
4. **Plan Globally Unique Names**: Ensure Front Door names are globally unique
5. **Consider Tier Selection**: Choose Standard or Premium based on requirements

## Additional Resources

- [Front Door Profile Resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/frontdoor)
- [Azure Front Door Overview](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-overview)
- [Front Door Tiers](https://learn.microsoft.com/en-us/azure/frontdoor/standard-premium/tier-comparison)

