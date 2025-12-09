# DNS Records

## Overview

DNS records define how domain names resolve to IP addresses or other records. Azure DNS supports all standard DNS record types for both public and private zones.

**Supported Record Types:**
- **A**: IPv4 address mapping
- **AAAA**: IPv6 address mapping
- **CNAME**: Canonical name (alias)
- **MX**: Mail exchange
- **NS**: Name server (auto-created for zones)
- **PTR**: Pointer (reverse DNS)
- **SRV**: Service location
- **TXT**: Text record
- **SOA**: Start of Authority (auto-created, not user-configurable)

## A Records (IPv4 Address)

A records map hostnames to IPv4 addresses. They are the most common DNS record type.

### Basic A Record

```hcl
resource "azurerm_dns_a_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600
  records             = ["20.1.1.1"]
}
```

### Multiple IP Addresses

Multiple A records with the same name provide load balancing and redundancy.

```hcl
resource "azurerm_dns_a_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = ["20.1.1.1", "20.1.1.2", "20.1.1.3"]
}
```

### Root Domain A Record

Use "@" for the root domain.

```hcl
resource "azurerm_dns_a_record" "root" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600
  records             = ["20.1.1.1"]
}
```

### Private DNS A Record

```hcl
resource "azurerm_private_dns_a_record" "app" {
  name                = "app1"
  zone_name           = azurerm_private_dns_zone.private.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = ["10.0.1.10"]
}
```

## AAAA Records (IPv6 Address)

AAAA records map hostnames to IPv6 addresses.

### Basic AAAA Record

```hcl
resource "azurerm_dns_aaaa_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600
  records             = ["2001:0db8:85a3:0000:0000:8a2e:0370:7334"]
}
```

### Multiple IPv6 Addresses

```hcl
resource "azurerm_dns_aaaa_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600
  records             = [
    "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
    "2001:0db8:85a3:0000:0000:8a2e:0370:7335"
  ]
}
```

## CNAME Records (Canonical Name)

CNAME records create an alias from one domain name to another.

### Basic CNAME Record

```hcl
resource "azurerm_dns_cname_record" "alias" {
  name                = "www-alias"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600
  record              = "www.contoso.com"
}
```

### CNAME Limitations

**Important**: 
- Cannot create CNAME at root domain (@)
- Cannot create other record types with the same name as a CNAME
- CNAME must point to a fully qualified domain name (FQDN)

### Private DNS CNAME

```hcl
resource "azurerm_private_dns_cname_record" "api" {
  name                = "api"
  zone_name           = azurerm_private_dns_zone.private.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  record              = "api-backend.internal.contoso.com"
}
```

## MX Records (Mail Exchange)

MX records specify mail servers responsible for accepting email for the domain.

### Basic MX Record

```hcl
resource "azurerm_dns_mx_record" "mail" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600

  record {
    preference = 10
    exchange   = "mail1.contoso.com"
  }
}
```

### Multiple MX Records

Multiple MX records provide mail server redundancy. Lower preference numbers have higher priority.

```hcl
resource "azurerm_dns_mx_record" "mail" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600

  record {
    preference = 10
    exchange   = "mail1.contoso.com"
  }

  record {
    preference = 20
    exchange   = "mail2.contoso.com"
  }

  record {
    preference = 30
    exchange   = "mail3.contoso.com"
  }
}
```

## TXT Records (Text Records)

TXT records store text information, commonly used for email authentication and domain verification.

### SPF Record

```hcl
resource "azurerm_dns_txt_record" "spf" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600

  record {
    value = "v=spf1 include:spf.contoso.com -all"
  }
}
```

### DMARC Record

```hcl
resource "azurerm_dns_txt_record" "dmarc" {
  name                = "_dmarc"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600

  record {
    value = "v=DMARC1; p=reject; rua=mailto:dmarc@contoso.com"
  }
}
```

### Multiple TXT Values

TXT records can have multiple values. Azure automatically concatenates them.

```hcl
resource "azurerm_dns_txt_record" "verification" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600

  record {
    value = "google-site-verification=abc123..."
  }

  record {
    value = "v=spf1 include:spf.contoso.com -all"
  }
}
```

### Domain Verification

```hcl
resource "azurerm_dns_txt_record" "verification" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600

  record {
    value = "google-site-verification=abc123def456"
  }
}
```

## Time To Live (TTL)

TTL controls how long DNS resolvers cache DNS records.

### TTL Best Practices

**Short TTL (300-600 seconds):**
- Records that change frequently
- During DNS migrations
- For testing and development

**Medium TTL (3600 seconds / 1 hour):**
- Standard for most production records
- Balance between flexibility and performance

**Long TTL (86400 seconds / 24 hours):**
- Stable records that rarely change
- Reduces DNS query costs
- Slower change propagation

### Dynamic TTL Configuration

```hcl
locals {
  # Short TTL for dynamic records
  dynamic_ttl = 300
  
  # Medium TTL for standard records
  standard_ttl = 3600
  
  # Long TTL for static records
  static_ttl = 86400
}

resource "azurerm_dns_a_record" "dynamic" {
  name                = "api"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = local.dynamic_ttl
  records             = ["20.1.1.1"]
}

resource "azurerm_dns_a_record" "static" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = local.static_ttl
  records             = ["20.1.1.1"]
}
```

## Managing Multiple Records

### Using for_each

```hcl
locals {
  a_records = {
    "www"     = ["20.1.1.1", "20.1.1.2"]
    "api"     = ["20.1.1.10"]
    "mail"    = ["20.1.1.20"]
    "blog"    = ["20.1.1.30"]
  }
}

resource "azurerm_dns_a_record" "records" {
  for_each = local.a_records

  name                = each.key
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600
  records             = each.value
}
```

### Multiple Record Types

```hcl
# A Records
resource "azurerm_dns_a_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600
  records             = ["20.1.1.1"]
}

# CNAME Record
resource "azurerm_dns_cname_record" "alias" {
  name                = "www-alias"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600
  record              = "www.contoso.com"
}

# MX Record
resource "azurerm_dns_mx_record" "mail" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600

  record {
    preference = 10
    exchange   = "mail.contoso.com"
  }
}
```

## Complete Example

```hcl
# Public DNS Zone
resource "azurerm_dns_zone" "public" {
  name                = "contoso.com"
  resource_group_name = azurerm_resource_group.main.name
}

# Root Domain A Record
resource "azurerm_dns_a_record" "root" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600
  records             = ["20.1.1.1"]
}

# WWW A Record with Multiple IPs
resource "azurerm_dns_a_record" "www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = ["20.1.1.1", "20.1.1.2", "20.1.1.3"]
}

# API CNAME
resource "azurerm_dns_cname_record" "api" {
  name                = "api"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600
  record              = "api-backend.contoso.com"
}

# Mail MX Records
resource "azurerm_dns_mx_record" "mail" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600

  record {
    preference = 10
    exchange   = "mail1.contoso.com"
  }

  record {
    preference = 20
    exchange   = "mail2.contoso.com"
  }
}

# SPF TXT Record
resource "azurerm_dns_txt_record" "spf" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 3600

  record {
    value = "v=spf1 include:spf.contoso.com -all"
  }
}
```

## Best Practices

1. **TTL Strategy**: Use appropriate TTL values based on change frequency
2. **Multiple IPs**: Use multiple A records for high availability
3. **CNAME Limitations**: Avoid CNAME at root domain
4. **Record Naming**: Use consistent naming conventions
5. **Email Records**: Configure SPF, DKIM, and DMARC for email domains
6. **Documentation**: Document DNS record purposes and dependencies

## Troubleshooting

### Record Not Resolving

- Check TTL hasn't expired (wait for TTL period)
- Verify record exists in Azure Portal
- Check for typos in record name or zone name
- Verify zone is properly delegated (for public zones)

### CNAME Conflicts

- Cannot have CNAME and other record types with same name
- Cannot create CNAME at root domain
- Use A records instead of CNAME at root

## Additional Resources

- [DNS Record Types](https://learn.microsoft.com/en-us/azure/dns/dns-zones-records)
- [Terraform DNS Resources](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record)
- [TTL Best Practices](https://learn.microsoft.com/en-us/azure/dns/dns-best-practices)

