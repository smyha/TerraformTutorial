# Private DNS Zones

## Overview

Private DNS zones in Azure provide internal name resolution for virtual networks. They are not accessible from the Internet and are globally scoped, meaning they can be accessed from any region, subscription, or virtual network (with proper permissions).

**Key Characteristics:**
- Internal-only name resolution
- Globally scoped (any region, subscription, VNet)
- Requires virtual network links for name resolution
- Supports automatic VM hostname registration
- Can be shared across multiple virtual networks

## Creating a Private DNS Zone

### Basic Configuration

```hcl
resource "azurerm_private_dns_zone" "private" {
  name                = "internal.contoso.com"
  resource_group_name = azurerm_resource_group.main.name
}
```

### With Tags

```hcl
resource "azurerm_private_dns_zone" "private" {
  name                = "internal.contoso.com"
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = "Production"
    Purpose     = "Internal Services"
  }
}
```

## Virtual Network Links

Private DNS zones require virtual network links to enable name resolution. A link connects a private DNS zone to a virtual network.

### Basic VNet Link

```hcl
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name  = azurerm_private_dns_zone.private.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
}
```

### VNet Link with Auto-Registration

When `registration_enabled = true`, VMs in the linked virtual network automatically register their hostnames in the private DNS zone.

```hcl
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name  = azurerm_private_dns_zone.private.name
  virtual_network_id     = azurerm_virtual_network.main.id
  registration_enabled   = true  # Auto-register VMs
}
```

### Multiple VNet Links

One private DNS zone can link to multiple virtual networks, enabling cross-VNet name resolution.

```hcl
locals {
  vnets = {
    vnet1 = azurerm_virtual_network.vnet1.id
    vnet2 = azurerm_virtual_network.vnet2.id
    vnet3 = azurerm_virtual_network.vnet3.id
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  for_each = local.vnets

  name                  = "vnet-link-${each.key}"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name  = azurerm_private_dns_zone.private.name
  virtual_network_id     = each.value
  registration_enabled   = true
}
```

## Auto-Registration

### How Auto-Registration Works

When `registration_enabled = true`:
- VMs automatically create A records with their hostname when they start
- Records are automatically removed when VMs are deleted
- Only works for VMs in the same subscription and region
- Hostname format: `{vm-name}.{private-dns-zone-name}`

### Auto-Registration Example

```hcl
# Private DNS Zone
resource "azurerm_private_dns_zone" "private" {
  name                = "internal.contoso.com"
  resource_group_name = azurerm_resource_group.main.name
}

# VNet Link with Auto-Registration
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name  = azurerm_private_dns_zone.private.name
  virtual_network_id     = azurerm_virtual_network.main.id
  registration_enabled   = true
}

# VM (will auto-register as vm-web.internal.contoso.com)
resource "azurerm_linux_virtual_machine" "web" {
  name                = "vm-web"
  resource_group_name  = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"

  network_interface_ids = [azurerm_network_interface.main.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
```

### When to Use Auto-Registration

**Use Auto-Registration When:**
- You want VMs to automatically register their hostnames
- You have many VMs that would be tedious to register manually
- VM hostnames match your naming convention

**Don't Use Auto-Registration When:**
- You need custom record names (not matching VM hostnames)
- You're registering non-VM resources (load balancers, app gateways, etc.)
- You need more control over DNS records

## Cross-VNet Name Resolution

Private DNS zones can be shared across multiple virtual networks, enabling service discovery across networks.

### Multi-VNet Configuration

```hcl
# Private DNS Zone
resource "azurerm_private_dns_zone" "private" {
  name                = "internal.contoso.com"
  resource_group_name = azurerm_resource_group.main.name
}

# VNet 1 Link
resource "azurerm_private_dns_zone_virtual_network_link" "vnet1" {
  name                  = "vnet1-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name  = azurerm_private_dns_zone.private.name
  virtual_network_id    = azurerm_virtual_network.vnet1.id
  registration_enabled   = true
}

# VNet 2 Link
resource "azurerm_private_dns_zone_virtual_network_link" "vnet2" {
  name                  = "vnet2-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name  = azurerm_private_dns_zone.private.name
  virtual_network_id    = azurerm_virtual_network.vnet2.id
  registration_enabled   = true
}

# VMs in VNet1 can resolve names from VNet2 and vice versa
```

## Complete Example

```hcl
# Resource Group
resource "azurerm_resource_group" "dns" {
  name     = "rg-dns-internal"
  location = "West Europe"
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.dns.location
  resource_group_name = azurerm_resource_group.dns.name
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "private" {
  name                = "internal.contoso.com"
  resource_group_name = azurerm_resource_group.dns.name

  tags = {
    Environment = "Production"
    Purpose     = "Internal Services"
  }
}

# VNet Link with Auto-Registration
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "vnet-main-link"
  resource_group_name   = azurerm_resource_group.dns.name
  private_dns_zone_name  = azurerm_private_dns_zone.private.name
  virtual_network_id     = azurerm_virtual_network.main.id
  registration_enabled   = true

  tags = {
    Environment = "Production"
  }
}

# Output Zone ID
output "private_dns_zone_id" {
  description = "Private DNS zone resource ID"
  value       = azurerm_private_dns_zone.private.id
}
```

## Best Practices

1. **Zone Naming**: Use descriptive names like `internal.contoso.com` for private zones
2. **Auto-Registration**: Enable for VMs when hostnames match your needs
3. **VNet Links**: Only link necessary virtual networks
4. **Zone Sharing**: Share zones across VNets for service discovery
5. **Manual Records**: Create manual records for non-VM resources
6. **Access Control**: Use Azure RBAC to control access to private zones

## Troubleshooting

### VMs Not Auto-Registering

- Verify `registration_enabled = true` on the VNet link
- Check that VM is in the linked virtual network
- Ensure VM is in the same subscription and region
- Verify VM hostname matches expected format

### Cross-VNet Resolution Not Working

- Verify both VNets are linked to the same private DNS zone
- Check that VNets have proper network connectivity (peering, etc.)
- Verify DNS records exist in the zone
- Check VNet DNS settings

## Additional Resources

- [Azure Private DNS](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview)
- [Auto-Registration](https://learn.microsoft.com/en-us/azure/dns/private-dns-autoregistration)
- [Terraform azurerm_private_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone)

