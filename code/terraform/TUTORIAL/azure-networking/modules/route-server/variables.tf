# ============================================================================
# Azure Route Server Module - Variables
# ============================================================================
# This module creates an Azure Route Server with BGP peer connections for NVAs.
# ============================================================================

variable "create_resource_group" {
  description = <<-EOT
    Whether to create a new resource group using the resource-group module.
    If true, the module will create a resource group using the project_name,
    application_name, and environment variables.
    If false, you must provide an existing resource_group_name.
  EOT
  type        = bool
  default     = false
}

variable "resource_group_name" {
  description = <<-EOT
    Name of the existing resource group (required if create_resource_group = false).
    This is ignored if create_resource_group = true.
  EOT
  type        = string
  default     = null
}

variable "project_name" {
  description = "The name of the project (required if create_resource_group = true)"
  type        = string
  default     = ""
}

variable "application_name" {
  description = "The name of the application (optional, used for resource group naming)"
  type        = string
  default     = ""
}

variable "environment" {
  description = "The environment for the resource group (required if create_resource_group = true)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = <<-EOT
    Azure region for the resource group (if create_resource_group = true).
    Also used as the location for Route Server if resource_group_location is not provided.
  EOT
  type        = string
  default     = "Spain Central"
}

variable "route_server_name" {
  description = "Name of the Azure Route Server"
  type        = string
}

variable "sku" {
  description = <<-EOT
    SKU for the Route Server.
    - Standard: High availability, zone-redundant support, recommended for production
  EOT
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard"], var.sku)
    error_message = "Route Server SKU must be 'Standard'."
  }
}

variable "subnet_id" {
  description = <<-EOT
    The ID of the subnet where Route Server will be deployed.
    
    Requirements:
    - Subnet must be named "RouteServerSubnet" (case-sensitive)
    - Subnet must be /27 or larger (minimum /27, recommended /26 or /25)
    - Subnet must be in the same VNet where you want to enable dynamic routing
    - Subnet should be dedicated to Route Server (no other resources)
  EOT
  type        = string
}

variable "branch_to_branch_traffic_enabled" {
  description = <<-EOT
    Whether to enable branch-to-branch traffic.
    When enabled, Route Server can exchange routes between:
    - Azure VPN Gateway
    - ExpressRoute Gateway
    - NVAs via BGP
    
    This enables dynamic routing between on-premises networks and Azure.
  EOT
  type        = bool
  default     = true
}

variable "bgp_peers" {
  description = <<-EOT
    Map of BGP peer connections (NVAs) to create.
    
    Each NVA that needs to exchange routes with Route Server requires a BGP peer.
    
    Example:
    bgp_peers = {
      "nva-firewall" = {
        name     = "bgp-firewall"
        peer_asn = 65001
        peer_ip  = "10.0.1.10"
      }
      "nva-router" = {
        name     = "bgp-router"
        peer_asn = 65002
        peer_ip  = "10.0.1.20"
      }
    }
    
    Requirements:
    - peer_asn: Must be different from Route Server's ASN (65515)
    - peer_ip: Must be the IP address of the NVA's interface in the VNet
    - NVA must have BGP enabled and IP forwarding enabled
  EOT
  type = map(object({
    name     = string
    peer_asn = number
    peer_ip  = string
  }))
  default = {}
}

variable "zones" {
  description = <<-EOT
    Availability zones for the public IP address.
    - null or []: No zone redundancy (default)
    - ["1", "2", "3"]: Zone-redundant (recommended for production)
    
    Note: Route Server Standard SKU supports zone redundancy.
  EOT
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default     = {}
}

