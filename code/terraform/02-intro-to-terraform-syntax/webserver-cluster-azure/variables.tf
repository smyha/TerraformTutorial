# ============================================================================
# Azure Authentication Variables
# ============================================================================
# These variables are required to authenticate with Azure. They should be
# provided via terraform.tfvars file or environment variables.
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
# These variables define the infrastructure configuration for the
# web server cluster deployment.
# ============================================================================

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-web-cluster"
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "westus2"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "production"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network (e.g., 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_address_prefixes" {
  description = "Address space for the subnet (e.g., 10.0.1.0/24)"
  type        = string
  default     = "10.0.1.0/24"
}

# ============================================================================
# Virtual Machine Scale Set Configuration
# ============================================================================
# Variables for configuring the VMSS and autoscaling behavior.
# ============================================================================

variable "vm_size" {
  description = "Azure VM size (SKU) for the scale set instances"
  type        = string
  default     = "Standard_B2s"

  validation {
    condition     = can(regex("Standard_", var.vm_size))
    error_message = "VM size must be a valid Azure Standard SKU."
  }
}

variable "instance_count" {
  description = "Initial number of VM instances in the scale set"
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "max_instance_count" {
  description = "Maximum number of instances for autoscaling"
  type        = number
  default     = 5

  validation {
    condition     = var.max_instance_count >= var.instance_count
    error_message = "Max instance count must be greater than or equal to instance count."
  }
}
