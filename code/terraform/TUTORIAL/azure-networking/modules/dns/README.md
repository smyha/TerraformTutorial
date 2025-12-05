# Azure DNS Module

This module creates Azure DNS zones (public and private) with DNS records.

## Features

- Public DNS zones for internet-facing domains
- Private DNS zones for internal name resolution
- Support for all standard DNS record types (A, AAAA, CNAME, MX, TXT, etc.)
- Automatic VM registration in private zones
- Virtual network links for private zones

## Usage

```hcl
module "dns" {
  source = "./modules/dns"
  
  resource_group_name = "rg-example"
  location           = "global"
  
  # Public DNS Zone
  dns_zones = {
    "example.com" = {
      zone_type = "Public"
    }
  }
  
  # DNS Records
  dns_records = {
    "example.com/www" = {
      zone_name = "example.com"
      name      = "www"
      type      = "A"
      ttl       = 300
      records   = ["1.2.3.4"]
    }
    "example.com/api" = {
      zone_name = "example.com"
      name      = "api"
      type      = "CNAME"
      ttl       = 300
      records   = ["www.example.com"]
    }
  }
  
  # Private DNS Zone
  dns_zones = {
    "internal.company" = {
      zone_type = "Private"
    }
  }
  
  # Private DNS Zone VNet Link
  private_dns_zone_virtual_network_links = {
    "internal.company/vnet-link" = {
      zone_name           = "internal.company"
      virtual_network_id  = azurerm_virtual_network.main.id
      registration_enabled = true
    }
  }
}
```

## Outputs

- `public_dns_zone_ids`: Map of public DNS zone names to IDs
- `public_dns_zone_nameservers`: Map of public DNS zone names to nameservers
- `private_dns_zone_ids`: Map of private DNS zone names to IDs
- `dns_record_ids`: Map of DNS record keys to IDs

