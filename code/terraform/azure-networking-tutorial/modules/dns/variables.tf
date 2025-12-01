# ============================================================================
# Azure DNS Module - Variables
# ============================================================================
# Azure DNS provides DNS hosting for your domains with high availability
# and global distribution.
# ============================================================================

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region (typically 'global' for DNS zones)"
  type        = string
  default     = "global"
}

variable "dns_zones" {
  description = <<-EOT
    Map of DNS zones to create.
    
    Example:
    dns_zones = {
      "example.com" = {
        zone_type = "Public"  # "Public" or "Private"
        tags = {
          Environment = "Production"
        }
      }
    }
  EOT
  type = map(object({
    zone_type = string # "Public" or "Private"
    tags       = optional(map(string), {})
  }))
  default = {}
}

variable "dns_records" {
  description = <<-EOT
    Map of DNS records to create.
    Key format: "{zone_name}/{record_name}"
    
    Example:
    dns_records = {
      "example.com/www" = {
        zone_name = "example.com"
        name      = "www"
        type      = "A"
        ttl       = 300
        records   = ["1.2.3.4"]
      }
    }
  EOT
  type = map(object({
    zone_name = string
    name      = string
    type      = string # "A", "AAAA", "CNAME", "MX", "NS", "PTR", "SRV", "TXT", "SOA"
    ttl       = number
    records   = list(string)
    tags      = optional(map(string), {})
  }))
  default = {}
}

variable "private_dns_zone_virtual_network_links" {
  description = <<-EOT
    Map of virtual network links for private DNS zones.
    
    Example:
    private_dns_zone_virtual_network_links = {
      "example.com/vnet-link" = {
        zone_name           = "example.com"
        virtual_network_id  = azurerm_virtual_network.main.id
        registration_enabled = true  # Auto-register VMs in the VNet
      }
    }
  EOT
  type = map(object({
    zone_name           = string
    virtual_network_id  = string
    registration_enabled = optional(bool, false)
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default     = {}
}

