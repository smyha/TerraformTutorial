# ============================================================================
# TERRAGRUNT CONFIGURATION: Azure Virtual Network Manager (Stage Environment)
# ============================================================================
# This file configures the Azure Virtual Network Manager module for the stage environment.
# Virtual Network Manager provides centralized network governance across multiple
# subscriptions and regions.
#
# Features configured:
# - Network Manager Instance with subscription scope
# - Network Groups (Production, Development, Shared Services)
# - Hub-and-Spoke Connectivity Configuration
# - Security Admin Rules (deny internet inbound, allow internal)
# - Routing Rules (next-hop to Azure Firewall)
#
# CONFIGURATION:
# - Variables can be overridden by creating a terraform.tfvars file in this directory
# - Or by setting environment variables (TF_VAR_*)
# - Default values are provided below
# ============================================================================

terraform {
  # Use repository URL for module source
  # Repository: git@github.com:smyha/TerraformTutorial.git
  # Path: terraform-up-and-running-code/code/terraform/TUTORIAL/azure-networking-tutorial/modules/virtual-network-manager
  source = "git::git@github.com:smyha/TerraformTutorial.git//terraform-up-and-running-code/code/terraform/TUTORIAL/azure-networking-tutorial/modules/virtual-network-manager"
}

include {
  path = find_in_parent_folders()
}

# ============================================================================
# LOCAL VALUES
# ============================================================================
# Local values can be used to compute values or set defaults
# These can be overridden via environment variables or terraform.tfvars
# ============================================================================
locals {
  # Default values - can be overridden via terraform.tfvars or environment variables
  network_manager_name = get_env("TF_VAR_network_manager_name", "nwm-stage")
  location             = get_env("TF_VAR_location", "eastus")
  resource_group_name  = get_env("TF_VAR_resource_group_name", "rg-network-management-stage")

  # Subscription IDs - set via environment variable or terraform.tfvars
  # Format: TF_VAR_scope_subscription_ids='["sub-id-1","sub-id-2"]'
  subscription_ids = try(
    jsondecode(get_env("TF_VAR_scope_subscription_ids", "[]")),
    []
  )
}

# ============================================================================
# DEPENDENCIES
# ============================================================================
# Virtual Network Manager may depend on:
# - Hub VNet (for hub-and-spoke topology)
# - Azure Firewall (for routing rules)
# ============================================================================

# Dependency: Hub Virtual Network (for hub-and-spoke topology)
dependency "hub_vnet" {
  config_path = "../networking/vnet"

  mock_outputs = {
    vnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-networking-stage/providers/Microsoft.Network/virtualNetworks/vnet-hub-stage"
  }

  skip_outputs = false
}

# Dependency: Azure Firewall (for routing rules - next-hop)
dependency "firewall" {
  config_path = "../firewall"

  mock_outputs = {
    firewall_private_ip = "10.0.1.4"
  }

  skip_outputs = false
}

# ============================================================================
# INPUTS: Module Configuration
# ============================================================================
# Variables can be provided via:
# 1. terraform.tfvars file (recommended) - copy terraform.tfvars.example to terraform.tfvars
# 2. Environment variables (TF_VAR_*)
# 3. Default values in locals block above
#
# To override values, create a terraform.tfvars file in this directory
# ============================================================================
inputs = {
  # Resource Group
  resource_group_name = local.resource_group_name
  location            = local.location
  network_manager_name = local.network_manager_name

  # Scope Configuration
  scope_subscription_ids = length(local.subscription_ids) > 0 ? local.subscription_ids : []
  scope_accesses        = ["Connectivity", "SecurityAdmin", "Routing"]

  description = "Network Manager for stage environment - centralized network governance"

  # Network Groups
  # Override these values by creating a terraform.tfvars file
  # See terraform.tfvars.example for the structure
  network_groups = {
    "production-vnets" = {
      description            = "Production virtual networks in stage environment"
      static_member_vnet_ids = []  # Add your VNet IDs here or in terraform.tfvars
    }
    "development-vnets" = {
      description            = "Development virtual networks in stage environment"
      static_member_vnet_ids = []  # Add your VNet IDs here or in terraform.tfvars
    }
  }

  # Connectivity Configurations
  # Hub VNet ID is resolved from dependency
  connectivity_configurations = {
    "hub-spoke-production" = {
      topology                        = "HubAndSpoke"
      network_group_names            = ["production-vnets"]
      group_connectivity              = "None"
      use_hub_gateway                 = true
      delete_existing_peering_enabled = false
      description                     = "Hub-and-spoke topology for production VNets"
      hub = {
        resource_id   = dependency.hub_vnet.outputs.vnet_id
        resource_type = "Microsoft.Network/virtualNetworks"
      }
    }
    "hub-spoke-development" = {
      topology                        = "HubAndSpoke"
      network_group_names            = ["development-vnets"]
      group_connectivity              = "None"
      use_hub_gateway                 = false
      delete_existing_peering_enabled = false
      description                     = "Hub-and-spoke topology for development VNets"
      hub = {
        resource_id   = dependency.hub_vnet.outputs.vnet_id
        resource_type = "Microsoft.Network/virtualNetworks"
      }
    }
  }

  # Security Admin Configurations
  security_admin_configurations = {
    "security-production" = {
      network_group_names = ["production-vnets"]
      description         = "Security admin rules for production VNets"
    }
    "security-development" = {
      network_group_names = ["development-vnets"]
      description         = "Security admin rules for development VNets"
    }
  }

  # Security Admin Rule Collections
  security_admin_rule_collections = {
    "deny-internet-production" = {
      security_admin_configuration_name = "security-production"
      network_group_names               = ["production-vnets"]
      description                       = "Deny internet traffic for production"
    }
    "allow-internal-production" = {
      security_admin_configuration_name = "security-production"
      network_group_names               = ["production-vnets"]
      description                       = "Allow internal traffic for production"
    }
  }

  # Security Admin Rules
  security_admin_rules = {
    "deny-all-internet-inbound-prod" = {
      rule_collection_name            = "deny-internet-production"
      priority                        = 100
      direction                       = "Inbound"
      action                          = "Deny"
      protocol                        = "Any"
      source_address_prefix_type      = "ServiceTag"
      source_address_prefix           = "Internet"
      destination_address_prefix_type = "IPPrefix"
      destination_address_prefix      = "0.0.0.0/0"
      source_port_ranges              = ["0-65535"]
      destination_port_ranges         = ["0-65535"]
      description                     = "Deny all inbound internet traffic to production VNets"
    }
    "allow-internal-vnet-prod" = {
      rule_collection_name            = "allow-internal-production"
      priority                        = 200
      direction                       = "Inbound"
      action                          = "Allow"
      protocol                        = "Any"
      source_address_prefix_type      = "ServiceTag"
      source_address_prefix           = "VirtualNetwork"
      destination_address_prefix_type = "IPPrefix"
      destination_address_prefix      = "0.0.0.0/0"
      source_port_ranges              = []
      destination_port_ranges         = []
      description                     = "Allow internal VNet traffic for production"
    }
  }

  # Routing Configurations
  routing_configurations = {
    "routing-production" = {
      network_group_names = ["production-vnets"]
      description         = "Routing configuration for production VNets - force traffic through firewall"
    }
  }

  # Routing Rule Collections
  routing_rule_collections = {
    "firewall-routing-production" = {
      routing_configuration_name = "routing-production"
      network_group_names        = ["production-vnets"]
      description                = "Route all traffic through Azure Firewall"
    }
  }

  # Routing Rules
  # Firewall IP is resolved from dependency
  routing_rules = {
    "route-internet-to-firewall" = {
      rule_collection_name = "firewall-routing-production"
      description          = "Route all internet traffic (0.0.0.0/0) through Azure Firewall"
      destination_type     = "AddressPrefix"
      destination_address  = "0.0.0.0/0"
      next_hop_type        = "VirtualAppliance"
      next_hop_address     = dependency.firewall.outputs.firewall_private_ip
    }
    "route-azure-storage" = {
      rule_collection_name = "firewall-routing-production"
      description          = "Route Azure Storage traffic through firewall"
      destination_type     = "ServiceTag"
      destination_address  = "Storage"
      next_hop_type        = "VirtualAppliance"
      next_hop_address     = dependency.firewall.outputs.firewall_private_ip
    }
  }

  # Deployments
  # Configuration IDs need to be populated after first apply
  # Override in terraform.tfvars after getting IDs from outputs
  deployments = {
    "deploy-connectivity-eastus" = {
      location          = local.location
      scope_access      = "Connectivity"
      configuration_ids = []  # Populate after first apply
    }
    "deploy-security-eastus" = {
      location          = local.location
      scope_access      = "SecurityAdmin"
      configuration_ids = []  # Populate after first apply
    }
    "deploy-routing-eastus" = {
      location          = local.location
      scope_access      = "Routing"
      configuration_ids = []  # Populate after first apply
    }
  }

  # Tags
  tags = {
    Environment = "stage"
    Component   = "virtual-network-manager"
    ManagedBy   = "Terragrunt"
  }
}

# ============================================================================
# NOTES:
# ============================================================================
# 1. To override values, create a terraform.tfvars file in this directory
#    Copy terraform.tfvars.example to terraform.tfvars and update values
# 2. Subscription IDs: Update scope_subscription_ids in terraform.tfvars
# 3. VNet IDs: Add your VNet resource IDs to network_groups in terraform.tfvars
# 4. Deployments: Configuration IDs in deployments need to be populated after first apply
#    - First apply: Creates configurations
#    - Second apply: Deploys configurations with IDs from first apply
# 5. Management Group Scope: For production, consider using Management Group scope
#    instead of subscription scope for enterprise-wide governance
# ============================================================================
