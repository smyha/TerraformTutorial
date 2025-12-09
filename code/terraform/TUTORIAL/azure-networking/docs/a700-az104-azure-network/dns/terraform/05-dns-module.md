# DNS Module Usage

## Overview

The Azure DNS module provides a comprehensive solution for managing DNS zones and records in Azure. It supports both public and private DNS zones, all standard DNS record types, and virtual network links for private zones.

**Module Features:**
- Public and private DNS zones
- All standard DNS record types
- Virtual network links with auto-registration
- Flexible resource group management
- Comprehensive tagging support

## Module Location

```
modules/dns/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

## Basic Usage

### Public DNS Zone

```hcl
module "dns" {
  source = "../../modules/dns"

  create_resource_group = true
  project_name         = "webapp"
  application_name     = "contoso"
  environment          = "prod"
  location             = "West Europe"

  dns_zones = {
    "contoso.com" = {
      zone_type = "Public"
      tags = {
        Environment = "Production"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}
```

### Private DNS Zone

```hcl
module "dns" {
  source = "../../modules/dns"

  create_resource_group = true
  project_name         = "webapp"
  application_name     = "contoso"
  environment          = "prod"
  location             = "West Europe"

  dns_zones = {
    "internal.contoso.com" = {
      zone_type = "Private"
      tags = {
        Environment = "Production"
        Purpose     = "Internal Services"
      }
    }
  }

  private_dns_zone_virtual_network_links = {
    "internal.contoso.com/vnet-link" = {
      zone_name           = "internal.contoso.com"
      virtual_network_id  = azurerm_virtual_network.main.id
      registration_enabled = true
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Complete Example

### Public and Private Zones with Records

```hcl
# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.main.name
}

# DNS Module
module "dns" {
  source = "../../modules/dns"

  create_resource_group = true
  project_name         = "webapp"
  application_name     = "contoso"
  environment          = "prod"
  location             = "West Europe"

  # Public DNS Zone
  dns_zones = {
    "contoso.com" = {
      zone_type = "Public"
      tags = {
        Environment = "Production"
        Domain      = "contoso.com"
      }
    }
    # Private DNS Zone
    "internal.contoso.com" = {
      zone_type = "Private"
      tags = {
        Environment = "Production"
        Purpose     = "Internal Services"
      }
    }
  }

  # DNS Records
  dns_records = {
    # Public A Records
    "contoso.com/www" = {
      zone_name = "contoso.com"
      name      = "www"
      type      = "A"
      ttl       = 300
      records   = ["20.1.1.1", "20.1.1.2"]
    }
    "contoso.com/@" = {
      zone_name = "contoso.com"
      name      = "@"
      type      = "A"
      ttl       = 3600
      records   = ["20.1.1.1"]
    }
    # Public CNAME
    "contoso.com/api" = {
      zone_name = "contoso.com"
      name      = "api"
      type      = "CNAME"
      ttl       = 3600
      records   = ["api-backend.contoso.com"]
    }
    # Public MX
    "contoso.com/mail" = {
      zone_name = "contoso.com"
      name      = "@"
      type      = "MX"
      ttl       = 3600
      records   = ["10 mail1.contoso.com", "20 mail2.contoso.com"]
    }
    # Public TXT (SPF)
    "contoso.com/spf" = {
      zone_name = "contoso.com"
      name      = "@"
      type      = "TXT"
      ttl       = 3600
      records   = ["v=spf1 include:spf.contoso.com -all"]
    }
    # Private A Record
    "internal.contoso.com/app1" = {
      zone_name = "internal.contoso.com"
      name      = "app1"
      type      = "A"
      ttl       = 300
      records   = ["10.0.1.10"]
    }
  }

  # Private DNS Zone VNet Links
  private_dns_zone_virtual_network_links = {
    "internal.contoso.com/vnet-main-link" = {
      zone_name           = "internal.contoso.com"
      virtual_network_id  = azurerm_virtual_network.main.id
      registration_enabled = true
      tags = {
        VNet = "vnet-main"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
    Project   = "Contoso Web Application"
  }
}

# Outputs
output "public_zone_name_servers" {
  description = "Name servers for public zone delegation"
  value       = module.dns.public_dns_zone_nameservers["contoso.com"]
}

output "private_zone_id" {
  description = "Private DNS zone ID"
  value       = module.dns.private_dns_zone_ids["internal.contoso.com"]
}
```

## Using Existing Resource Group

```hcl
module "dns" {
  source = "../../modules/dns"

  create_resource_group = false
  resource_group_name  = "rg-existing-dns"

  dns_zones = {
    "contoso.com" = {
      zone_type = "Public"
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Multiple Zones and Records

```hcl
locals {
  domains = {
    "contoso.com"        = "Public"
    "fabrikam.com"       = "Public"
    "internal.contoso.com" = "Private"
  }

  public_records = {
    "contoso.com/www" = {
      zone_name = "contoso.com"
      name      = "www"
      type      = "A"
      ttl       = 3600
      records   = ["20.1.1.1"]
    }
    "fabrikam.com/www" = {
      zone_name = "fabrikam.com"
      name      = "www"
      type      = "A"
      ttl       = 3600
      records   = ["20.2.1.1"]
    }
  }

  private_records = {
    "internal.contoso.com/app1" = {
      zone_name = "internal.contoso.com"
      name      = "app1"
      type      = "A"
      ttl       = 300
      records   = ["10.0.1.10"]
    }
  }
}

module "dns" {
  source = "../../modules/dns"

  create_resource_group = true
  project_name         = "multidomain"
  environment          = "prod"
  location             = "West Europe"

  dns_zones = {
    for domain, type in local.domains : domain => {
      zone_type = type
      tags = {
        Domain = domain
      }
    }
  }

  dns_records = merge(
    local.public_records,
    local.private_records
  )

  private_dns_zone_virtual_network_links = {
    "internal.contoso.com/vnet-link" = {
      zone_name           = "internal.contoso.com"
      virtual_network_id  = azurerm_virtual_network.main.id
      registration_enabled = true
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Module Variables

### Required Variables

- `dns_zones`: Map of DNS zones to create (can be empty)
- `location`: Azure region (required if `create_resource_group = true`)

### Optional Variables

- `create_resource_group`: Whether to create resource group (default: `false`)
- `resource_group_name`: Existing resource group name (required if `create_resource_group = false`)
- `project_name`: Project name for resource group naming
- `application_name`: Application name for resource group naming
- `environment`: Environment name (default: `"dev"`)
- `dns_records`: Map of DNS records to create
- `private_dns_zone_virtual_network_links`: Map of VNet links for private zones
- `tags`: Default tags for all resources

## Module Outputs

### Available Outputs

```hcl
# Public DNS Zone IDs
output "public_zone_ids" {
  value = module.dns.public_dns_zone_ids
}

# Public DNS Zone Name Servers
output "public_zone_nameservers" {
  value = module.dns.public_dns_zone_nameservers
}

# Private DNS Zone IDs
output "private_zone_ids" {
  value = module.dns.private_dns_zone_ids
}

# DNS Record IDs
output "record_ids" {
  value = module.dns.dns_record_ids
}

# Resource Group Name
output "resource_group_name" {
  value = module.dns.resource_group_name
}
```

### Using Outputs

```hcl
# Get name servers for delegation
output "contoso_name_servers" {
  description = "Name servers for contoso.com delegation"
  value       = module.dns.public_dns_zone_nameservers["contoso.com"]
}

# Get private zone ID for other resources
output "internal_zone_id" {
  description = "Internal DNS zone ID"
  value       = module.dns.private_dns_zone_ids["internal.contoso.com"]
}
```

## Best Practices

### Zone Organization

1. **Group Related Zones**: Use the same resource group for related zones
2. **Consistent Naming**: Use consistent naming conventions
3. **Tagging Strategy**: Use tags for cost management and organization

### Record Management

1. **TTL Strategy**: Use appropriate TTL values
2. **Record Naming**: Use consistent record naming
3. **Multiple IPs**: Use multiple A records for high availability

### Private Zones

1. **Auto-Registration**: Enable for VMs when appropriate
2. **VNet Links**: Only link necessary virtual networks
3. **Zone Sharing**: Share zones across VNets for service discovery

### Module Usage

1. **Resource Groups**: Create dedicated resource groups for DNS
2. **Version Pinning**: Pin module version in production
3. **Output Usage**: Use outputs for delegation and integration
4. **Documentation**: Document DNS configuration and dependencies

## Troubleshooting

### Module Errors

**Error: Resource group not found**
- Set `create_resource_group = true` or provide existing `resource_group_name`
- Verify resource group exists and is accessible

**Error: Zone already exists**
- Check if zone exists in another resource group
- Verify zone name is correct

**Error: Invalid record type**
- Verify record type is supported (A, AAAA, CNAME, MX, TXT)
- Check record format matches type requirements

### Common Issues

**Records not created**
- Verify zone exists before creating records
- Check record key format: `"{zone_name}/{record_name}"`
- Verify zone_type matches (Public vs Private)

**VNet links not working**
- Verify virtual network ID is correct
- Check private zone exists
- Verify registration_enabled setting

## Additional Resources

- [DNS Module Source](../../../../modules/dns/)
- [Module README](../../../../modules/dns/README.md)
- [Azure DNS Documentation](https://learn.microsoft.com/en-us/azure/dns/)

