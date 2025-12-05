# ============================================================================
# Azure Virtual Network Module - Variables
# ============================================================================
# This module creates an Azure Virtual Network (VNet) with subnets.
#
# Virtual Networks are the fundamental building blocks of Azure networking.
# They provide isolation and segmentation for your Azure resources.
# ============================================================================

variable "resource_group_name" {
  description = "Name of the resource group where the VNet will be created"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created (e.g., 'eastus', 'westeurope')"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network. Should be descriptive (e.g., 'prod-vnet', 'hub-vnet')"
  type        = string
}

variable "address_space" {
  description = <<-EOT
    List of address spaces (CIDR blocks) for the VNet.
    Example: ['10.0.0.0/16'] or ['10.0.0.0/16', '172.16.0.0/16']
    
    Important:
    - Address space cannot be changed after creation
    - Must not overlap with on-premises networks if connecting via VPN/ExpressRoute
    - Plan carefully for future growth and connectivity requirements
  EOT
  type        = list(string)
  
  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one address space must be specified."
  }
}

variable "subnets" {
  description = <<-EOT
    Map of subnet configurations. Each subnet can have:
    - address_prefixes: List of CIDR blocks for the subnet (must be within VNet address space)
    - service_endpoints: List of service endpoints to enable (e.g., ["Microsoft.Storage", "Microsoft.Sql"])
    - delegation: Service delegation configuration (for AKS, App Service, etc.)
    - private_endpoint_network_policies_enabled: Enable/disable private endpoint network policies
    - private_link_service_network_policies_enabled: Enable/disable private link service network policies
    
    Example:
    subnets = {
      "subnet-web" = {
        address_prefixes = ["10.0.1.0/24"]
        service_endpoints = ["Microsoft.Storage"]
        private_endpoint_network_policies_enabled = true
        private_link_service_network_policies_enabled = true
      }
      "subnet-app" = {
        address_prefixes = ["10.0.2.0/24"]
        service_endpoints = ["Microsoft.Sql"]
      }
      "GatewaySubnet" = {
        address_prefixes = ["10.0.0.0/27"]  # Minimum /27 for VPN/ExpressRoute Gateway
      }
    }
    
    Note: Azure reserves 5 IP addresses per subnet:
    - Network address (first)
    - Default gateway (second)
    - Two Azure DNS addresses (third and fourth)
    - Broadcast address (last)
  EOT
  type = map(object({
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    delegation                                    = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }), null)
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
  }))
  
  default = {}
}

variable "dns_servers" {
  description = <<-EOT
    List of custom DNS servers for the VNet.
    If empty, Azure's default DNS (168.63.129.16) is used.
    
    Use cases:
    - Hybrid scenarios: Resolve on-premises resources
    - Custom DNS infrastructure: Use your own DNS servers
    - Active Directory: Use domain controllers as DNS servers
    
    Example: ["10.0.0.4", "10.0.0.5", "8.8.8.8"]
  EOT
  type        = list(string)
  default     = []
}

variable "ddos_protection_plan_id" {
  description = <<-EOT
    Optional ID of a DDoS Protection Plan to associate with the VNet.
    Leave null to disable DDoS protection.
    
    DDoS Protection Plan must be created separately (Standard tier).
    This is a paid service that provides advanced DDoS mitigation.
  EOT
  type        = string
  default     = null
}

variable "enable_ddos_protection" {
  description = <<-EOT
    Enable DDoS protection on the VNet.
    Requires ddos_protection_plan_id to be set.
    
    Note: DDoS Protection Standard is a paid service.
    Basic DDoS protection is always enabled (free).
  EOT
  type        = bool
  default     = false
}

variable "tags" {
  description = "Map of tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}


