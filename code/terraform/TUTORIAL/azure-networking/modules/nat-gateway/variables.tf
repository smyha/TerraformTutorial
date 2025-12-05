# ============================================================================
# Azure NAT Gateway Module - Variables
# ============================================================================
# Azure NAT Gateway provides outbound internet connectivity for virtual networks.
# It's a fully managed, highly resilient service that scales automatically.
#
# Key Features:
# - Outbound-only NAT (SNAT - Source Network Address Translation)
# - Up to 64,000 concurrent flows per public IP
# - Automatic scaling
# - No downtime during maintenance
# - Zone-redundant (Standard SKU)
# ============================================================================

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "nat_gateway_name" {
  description = "Name of the NAT Gateway"
  type        = string
}

variable "public_ip_address_ids" {
  description = "List of public IP address IDs to associate with the NAT Gateway. At least one is required."
  type        = list(string)
  
  validation {
    condition     = length(var.public_ip_address_ids) > 0
    error_message = "At least one public IP address ID must be provided."
  }
}

variable "idle_timeout_in_minutes" {
  description = "Idle timeout in minutes. Default is 4 minutes. Range: 4-120."
  type        = number
  default     = 4
  
  validation {
    condition     = var.idle_timeout_in_minutes >= 4 && var.idle_timeout_in_minutes <= 120
    error_message = "Idle timeout must be between 4 and 120 minutes."
  }
}

variable "zones" {
  description = "Availability zones for the NAT Gateway. Standard SKU supports zone-redundant (all zones)."
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "Map of tags"
  type        = map(string)
  default     = {}
}

