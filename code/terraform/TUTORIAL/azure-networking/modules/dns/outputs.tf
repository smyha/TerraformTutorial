# ============================================================================
# Azure DNS Module - Outputs
# ============================================================================

output "public_dns_zone_ids" {
  description = "Map of public DNS zone names to their IDs"
  value = {
    for zone_name, zone in azurerm_dns_zone.public : zone_name => zone.id
  }
}

output "public_dns_zone_nameservers" {
  description = "Map of public DNS zone names to their nameservers"
  value = {
    for zone_name, zone in azurerm_dns_zone.public : zone_name => zone.name_servers
  }
}

output "private_dns_zone_ids" {
  description = "Map of private DNS zone names to their IDs"
  value = {
    for zone_name, zone in azurerm_private_dns_zone.private : zone_name => zone.id
  }
}

output "dns_record_ids" {
  description = "Map of DNS record keys to their IDs"
  value = merge(
    { for key, record in azurerm_dns_a_record.public : key => record.id },
    { for key, record in azurerm_dns_aaaa_record.public : key => record.id },
    { for key, record in azurerm_dns_cname_record.public : key => record.id },
    { for key, record in azurerm_dns_mx_record.public : key => record.id },
    { for key, record in azurerm_dns_txt_record.public : key => record.id },
    { for key, record in azurerm_private_dns_a_record.private : key => record.id },
    { for key, record in azurerm_private_dns_cname_record.private : key => record.id }
  )
}

