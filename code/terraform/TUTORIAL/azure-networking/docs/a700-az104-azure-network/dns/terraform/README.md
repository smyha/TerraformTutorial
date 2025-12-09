# Terraform Implementation Guides for Azure DNS

This directory contains comprehensive guides for implementing Azure DNS services using Terraform.

## Documentation Structure

1. **[01-public-dns-zones.md](./01-public-dns-zones.md)**
   - Creating public DNS zones
   - Zone configuration and naming
   - Name server assignment

2. **[02-private-dns-zones.md](./02-private-dns-zones.md)**
   - Creating private DNS zones
   - Virtual network links
   - Auto-registration configuration

3. **[03-dns-records.md](./03-dns-records.md)**
   - Creating DNS records (A, AAAA, CNAME, MX, TXT)
   - Record configuration and TTL
   - Multiple record management

4. **[04-dns-delegation.md](./04-dns-delegation.md)**
   - Domain delegation to Azure DNS
   - Subdomain configuration
   - NS record management

5. **[05-dns-module.md](./05-dns-module.md)**
   - Using the DNS module
   - Module configuration examples
   - Best practices

## Quick Start

### Public DNS Zone

```hcl
# Resource Group
resource "azurerm_resource_group" "dns" {
  name     = "rg-dns"
  location = "West Europe"
}

# Public DNS Zone
resource "azurerm_dns_zone" "public" {
  name                = "contoso.com"
  resource_group_name = azurerm_resource_group.dns.name
}

# A Record
resource "azurerm_dns_a_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.dns.name
  ttl                 = 3600
  records             = ["20.1.1.1"]
}
```

### Private DNS Zone

```hcl
# Private DNS Zone
resource "azurerm_private_dns_zone" "private" {
  name                = "internal.contoso.com"
  resource_group_name = azurerm_resource_group.dns.name
}

# Virtual Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.dns.name
  private_dns_zone_name = azurerm_private_dns_zone.private.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = true
}
```

## Module Usage

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
    }
  }

  dns_records = {
    "contoso.com/www" = {
      zone_name = "contoso.com"
      name      = "www"
      type      = "A"
      ttl       = 3600
      records   = ["20.1.1.1"]
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Additional Resources

- [Azure DNS Module](../../../../modules/dns/README.md)
- [Azure DNS Documentation](https://learn.microsoft.com/en-us/azure/dns/)
- [Terraform Azure DNS Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone)

