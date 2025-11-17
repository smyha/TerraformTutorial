# ============================================================================
# Azure Authentication Variables
# ============================================================================

variable "azure_client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
  sensitive   = true
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

# ============================================================================
# Infrastructure Configuration Variables
# ============================================================================

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-load-balancer"
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "westus2"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

# ============================================================================
# Network Configuration Variables
# ============================================================================

variable "vnet_address_space" {
  description = "Address space for Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "frontend_subnet_prefix" {
  description = "Address prefix for frontend subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "backend_subnet_prefix" {
  description = "Address prefix for backend subnet"
  type        = string
  default     = "10.0.2.0/24"
}

# ============================================================================
# Virtual Machine Configuration Variables
# ============================================================================

variable "backend_vm_count" {
  description = "Number of backend VMs to create"
  type        = number
  default     = 2

  validation {
    condition     = var.backend_vm_count >= 1 && var.backend_vm_count <= 10
    error_message = "Backend VM count must be between 1 and 10."
  }
}

variable "vm_size" {
  description = "Azure VM size (SKU)"
  type        = string
  default     = "Standard_B2s"

  validation {
    condition     = can(regex("Standard_", var.vm_size))
    error_message = "VM size must be a valid Azure Standard SKU."
  }
}

variable "admin_password" {
  description = "Admin password for backend VMs"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 8
    error_message = "Admin password must be at least 8 characters long."
  }
}
