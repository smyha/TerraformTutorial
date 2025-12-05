# ============================================================================
# TERRAGRUNT CONFIGURATION: Virtual Network (Stage Environment)
# ============================================================================
# This file configures the Virtual Network module for the stage environment.
# It demonstrates key Terragrunt features:
#   - include: Inherits remote_state config from parent
#   - inputs: Passes variables to the Terraform module
#   - source: Points to the reusable networking module
# ============================================================================

# ============================================================================
# TERRAFORM SOURCE
# ============================================================================
# Specifies which Terraform module to use. The double slash (//) is important:
# it tells Terragrunt to use the module at that path, not treat it as a
# relative path from the terragrunt.hcl file.
#
# Path breakdown:
#   ../../../../ = Go up 4 levels to repo root
#   modules// = The double slash means "use this exact path"
#   networking = The module directory
# ============================================================================
terraform {
  source = "../../../../modules//networking"
}

# ============================================================================
# INCLUDE BLOCK: Inherit Parent Configuration
# ============================================================================
# This block tells Terragrunt to look for and include the parent terragrunt.hcl
# file (in this case, live/stage/terragrunt.hcl).
#
# find_in_parent_folders():
#   - Searches up the directory tree for terragrunt.hcl
#   - Stops at the first one found (or repo root)
#   - Merges the parent's configuration with this file
#
# WHAT GETS INHERITED:
#   - remote_state configuration (backend settings)
#   - Any shared inputs from parent
# ============================================================================
include {
  path = find_in_parent_folders()
}

# ============================================================================
# INPUTS: Module Variables
# ============================================================================
# These are the input variables passed to the Terraform module. They override
# any defaults defined in the module's variables.tf file.
#
# Stage-specific configuration:
#   - Smaller address spaces for cost optimization
#   - Basic NSG rules for development/testing
#   - Standard SKU resources where applicable
# ============================================================================
inputs = {
  # Resource group configuration
  resource_group_name = "rg-networking-stage"
  location           = "eastus"

  # Virtual Network configuration
  vnet_name     = "vnet-stage"
  address_space = ["10.1.0.0/16"]

  # Subnet configuration
  subnets = {
    "web-subnet" = {
      address_prefixes = ["10.1.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
    "app-subnet" = {
      address_prefixes = ["10.1.2.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
    "db-subnet" = {
      address_prefixes = ["10.1.3.0/24"]
      service_endpoints = ["Microsoft.Sql"]
    }
    "gateway-subnet" = {
      address_prefixes = ["10.1.4.0/24"]
    }
  }

  # Network Security Groups
  network_security_groups = {
    "nsg-web" = {
      rules = [
        {
          name                       = "AllowHTTP"
          priority                   = 1000
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix       = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowHTTPS"
          priority                   = 1100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix       = "*"
          destination_address_prefix = "*"
        }
      ]
      associate_to_subnets = ["web-subnet"]
    }
    "nsg-app" = {
      rules = [
        {
          name                       = "AllowAppPort"
          priority                   = 1000
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8080"
          source_address_prefix      = "10.1.1.0/24"
          destination_address_prefix = "*"
        }
      ]
      associate_to_subnets = ["app-subnet"]
    }
  }

  # Route Tables (optional - for hub-spoke scenarios)
  route_tables = {}

  # DDoS Protection (optional - set to true for production)
  enable_ddos_protection = false
}

