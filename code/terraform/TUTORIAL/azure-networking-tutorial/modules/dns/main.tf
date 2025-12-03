# ============================================================================
# Azure DNS Module - Main Configuration
# ============================================================================
# Azure DNS provides DNS hosting for your domains with:
# - High availability (99.99% SLA)
# - Global distribution
# - Fast DNS resolution
# - Support for all standard DNS record types
# - Private DNS zones for internal name resolution
# ============================================================================

# ----------------------------------------------------------------------------
# Public DNS Zones
# ----------------------------------------------------------------------------
# Public DNS zones are used for internet-facing domains.
# They resolve DNS queries from anywhere on the Internet.
# ----------------------------------------------------------------------------
resource "azurerm_dns_zone" "public" {
  for_each = {
    for zone_name, zone_config in var.dns_zones : zone_name => zone_config
    if zone_config.zone_type == "Public"
  }
  
  name                = each.key
  resource_group_name = var.resource_group_name
  
  tags = merge(var.tags, each.value.tags)
}

# ----------------------------------------------------------------------------
# Private DNS Zones
# ----------------------------------------------------------------------------
# Private DNS zones are used for internal name resolution within Azure
# Virtual Networks. They are not accessible from the Internet.
# ----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "private" {
  for_each = {
    for zone_name, zone_config in var.dns_zones : zone_name => zone_config
    if zone_config.zone_type == "Private"
  }
  
  name                = each.key
  resource_group_name = var.resource_group_name
  
  tags = merge(var.tags, each.value.tags)
}

# ----------------------------------------------------------------------------
# DNS Records (Public Zones)
# ----------------------------------------------------------------------------
# DNS records define how domain names resolve to IP addresses or other records.
# Common record types:
# - A: IPv4 address
# - AAAA: IPv6 address
# - CNAME: Canonical name (alias)
# - MX: Mail exchange
# - NS: Name server
# - PTR: Pointer (reverse DNS)
# - SRV: Service record
# - TXT: Text record
# - SOA: Start of authority
# ----------------------------------------------------------------------------
resource "azurerm_dns_a_record" "public" {
  for_each = {
    for key, record in var.dns_records : key => record
    if record.type == "A" && try(azurerm_dns_zone.public[record.zone_name], null) != null
  }
  
  name                = each.value.name
  zone_name           = azurerm_dns_zone.public[each.value.zone_name].name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  
  tags = merge(var.tags, each.value.tags)
}

resource "azurerm_dns_aaaa_record" "public" {
  for_each = {
    for key, record in var.dns_records : key => record
    if record.type == "AAAA" && try(azurerm_dns_zone.public[record.zone_name], null) != null
  }
  
  name                = each.value.name
  zone_name           = azurerm_dns_zone.public[each.value.zone_name].name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  
  tags = merge(var.tags, each.value.tags)
}

resource "azurerm_dns_cname_record" "public" {
  for_each = {
    for key, record in var.dns_records : key => record
    if record.type == "CNAME" && try(azurerm_dns_zone.public[record.zone_name], null) != null
  }
  
  name                = each.value.name
  zone_name           = azurerm_dns_zone.public[each.value.zone_name].name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  record              = each.value.records[0]  # CNAME has single record
  
  tags = merge(var.tags, each.value.tags)
}

resource "azurerm_dns_mx_record" "public" {
  for_each = {
    for key, record in var.dns_records : key => record
    if record.type == "MX" && try(azurerm_dns_zone.public[record.zone_name], null) != null
  }
  
  name                = each.value.name
  zone_name           = azurerm_dns_zone.public[each.value.zone_name].name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  
  # MX records format: "priority mailserver"
  dynamic "record" {
    for_each = each.value.records
    content {
      preference = split(" ", record.value)[0]
      exchange   = split(" ", record.value)[1]
    }
  }
  
  tags = merge(var.tags, each.value.tags)
}

resource "azurerm_dns_txt_record" "public" {
  for_each = {
    for key, record in var.dns_records : key => record
    if record.type == "TXT" && try(azurerm_dns_zone.public[record.zone_name], null) != null
  }
  
  name                = each.value.name
  zone_name           = azurerm_dns_zone.public[each.value.zone_name].name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  
  tags = merge(var.tags, each.value.tags)
}

# ----------------------------------------------------------------------------
# Private DNS Records
# ----------------------------------------------------------------------------
resource "azurerm_private_dns_a_record" "private" {
  for_each = {
    for key, record in var.dns_records : key => record
    if record.type == "A" && try(azurerm_private_dns_zone.private[record.zone_name], null) != null
  }
  
  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.private[each.value.zone_name].name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  
  tags = merge(var.tags, each.value.tags)
}

resource "azurerm_private_dns_cname_record" "private" {
  for_each = {
    for key, record in var.dns_records : key => record
    if record.type == "CNAME" && try(azurerm_private_dns_zone.private[record.zone_name], null) != null
  }
  
  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.private[each.value.zone_name].name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  record              = each.value.records[0]
  
  tags = merge(var.tags, each.value.tags)
}

# ----------------------------------------------------------------------------
# Private DNS Zone Virtual Network Links
# ----------------------------------------------------------------------------
# Virtual network links connect private DNS zones to Virtual Networks.
# When registration_enabled is true, VMs in the VNet automatically
# register their hostnames in the private DNS zone.
# ----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  for_each = var.private_dns_zone_virtual_network_links
  
  name                  = split("/", each.key)[1]
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.zone_name
  virtual_network_id     = each.value.virtual_network_id
  registration_enabled  = each.value.registration_enabled
  
  tags = merge(var.tags, each.value.tags)
}

