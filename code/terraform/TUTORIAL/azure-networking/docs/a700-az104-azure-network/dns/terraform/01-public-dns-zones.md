# Public DNS Zones

## Overview

Public DNS zones in Azure DNS are used for internet-facing domains. They resolve DNS queries from anywhere on the Internet and are hosted on Azure's global network of DNS name servers.

**Key Characteristics:**
- Globally distributed across Azure's DNS infrastructure
- Automatically assigned 4 name servers when created
- Support for all standard DNS record types
- High availability with 99.99% SLA

## Creating a Public DNS Zone

### Basic Configuration

```hcl
resource "azurerm_dns_zone" "public" {
  name                = "contoso.com"
  resource_group_name = azurerm_resource_group.main.name
}
```

### With Tags

```hcl
resource "azurerm_dns_zone" "public" {
  name                = "contoso.com"
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = "Production"
    Project     = "Web Application"
    ManagedBy   = "Terraform"
  }
}
```

### Multiple Zones

```hcl
locals {
  domains = ["contoso.com", "fabrikam.com", "adatum.com"]
}

resource "azurerm_dns_zone" "public" {
  for_each = toset(local.domains)

  name                = each.value
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Domain = each.value
  }
}
```

## Zone Properties

### Name Server Assignment

When a public DNS zone is created, Azure automatically assigns 4 name servers from Azure's global DNS infrastructure. These name servers are available as an output.

**Accessing Name Servers:**

```hcl
output "name_servers" {
  value = azurerm_dns_zone.public.name_servers
}
```

**Example Output:**
```
name_servers = [
  "ns1-01.azure-dns.com",
  "ns2-01.azure-dns.net",
  "ns3-01.azure-dns.org",
  "ns4-01.azure-dns.info"
]
```

### Automatic Records

Azure automatically creates two record types when a DNS zone is created:

1. **SOA Record**: Start of Authority record (not user-configurable)
2. **NS Records**: Name Server records pointing to Azure's name servers

These records are automatically managed by Azure and cannot be manually created or modified.

## Zone Configuration Considerations

### Zone Name Uniqueness

- The DNS zone name must be unique within the resource group
- The zone must not already exist in Azure
- The same zone name can be reused in another resource group or subscription
- When multiple zones share the same name, each instance gets different name server addresses

### Resource Group Location

**Important**: DNS zones are global resources, but the resource group needs a location. The resource group location does not affect the DNS zone's global availability.

```hcl
resource "azurerm_resource_group" "dns" {
  name     = "rg-dns"
  location = "West Europe"  # Resource group location
}

resource "azurerm_dns_zone" "public" {
  name                = "contoso.com"
  resource_group_name = azurerm_resource_group.dns.name
  # Zone is globally available regardless of RG location
}
```

## Domain Delegation

After creating a public DNS zone, you must delegate your domain to Azure DNS at your domain registrar.

### Getting Name Servers

```hcl
output "name_servers" {
  description = "Name servers for domain delegation"
  value       = azurerm_dns_zone.public.name_servers
}
```

### Delegation Steps

1. Create the DNS zone in Azure
2. Get the 4 name servers from the zone output
3. Update NS records at your domain registrar
4. Wait for DNS propagation (can take up to 48 hours)

**Important**: Always use all four name servers provided by Azure DNS, regardless of your domain name.

## Complete Example

```hcl
# Resource Group
resource "azurerm_resource_group" "dns" {
  name     = "rg-dns-prod"
  location = "West Europe"

  tags = {
    Environment = "Production"
  }
}

# Public DNS Zone
resource "azurerm_dns_zone" "public" {
  name                = "contoso.com"
  resource_group_name = azurerm_resource_group.dns.name

  tags = {
    Environment = "Production"
    Project     = "Contoso Website"
    ManagedBy   = "Terraform"
  }
}

# Output Name Servers for Delegation
output "name_servers" {
  description = "Name servers to configure at domain registrar"
  value       = azurerm_dns_zone.public.name_servers
}

output "zone_id" {
  description = "DNS zone resource ID"
  value       = azurerm_dns_zone.public.id
}
```

## Best Practices

1. **Zone Naming**: Use your actual domain name as the zone name
2. **Resource Group**: Group related DNS zones in the same resource group
3. **Tagging**: Use consistent tags for cost management and organization
4. **Name Servers**: Always use all four name servers for delegation
5. **Documentation**: Document the delegation process for your team

## Troubleshooting

### Zone Already Exists

If you get an error that the zone already exists:
- Check if the zone exists in another resource group
- Check if the zone exists in another subscription
- Consider using data source to reference existing zone

### Name Server Not Available

Name servers are assigned immediately when the zone is created. If they're not showing:
- Wait a few moments for Azure to complete the assignment
- Check the zone resource in Azure Portal
- Verify the resource group exists

## Additional Resources

- [Azure DNS Zones](https://learn.microsoft.com/en-us/azure/dns/dns-zones-records)
- [Domain Delegation](https://learn.microsoft.com/en-us/azure/dns/dns-delegate-domain-azure-dns)
- [Terraform azurerm_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone)

