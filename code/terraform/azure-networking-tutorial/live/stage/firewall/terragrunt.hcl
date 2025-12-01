# ============================================================================
# TERRAGRUNT CONFIGURATION: Azure Firewall (Stage Environment)
# ============================================================================
# This file configures the Azure Firewall module for the stage environment.
# Azure Firewall provides centralized network security and filtering.
# ============================================================================

terraform {
  source = "../../../../modules//firewall"
}

include {
  path = find_in_parent_folders()
}

# ============================================================================
# DEPENDENCY: Virtual Network
# ============================================================================
# Azure Firewall requires a dedicated subnet in the VNet.
# The subnet must be named "AzureFirewallSubnet" and have at least /26 CIDR.
# ============================================================================
dependency "vnet" {
  config_path = "../networking/vnet"

  mock_outputs = {
    vnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-networking-stage/providers/Microsoft.Network/virtualNetworks/vnet-stage"
    vnet_name         = "vnet-stage"
    subnet_ids        = {}
    subnet_names      = []
  }

  skip_outputs = false
}

inputs = {
  resource_group_name = "rg-networking-stage"
  location           = "eastus"
  firewall_name      = "fw-stage"

  # Firewall SKU: Standard for basic features, Premium for advanced features
  sku_name    = "AZFW_VNet"
  sku_tier    = "Standard"
  firewall_policy_id = null # Optional: Use Azure Firewall Policy for centralized management

  # Virtual Network configuration
  # Note: The firewall subnet must be created separately with name "AzureFirewallSubnet"
  subnet_id = dependency.vnet.outputs.subnet_ids["firewall-subnet"] # Assuming firewall-subnet exists

  # Public IP configuration
  public_ip_count = 1 # Standard SKU supports 1 public IP, Premium supports multiple

  # Network rules (Layer 3/4 filtering)
  network_rule_collections = [
    {
      name     = "AllowOutboundHTTPS"
      priority = 100
      action   = "Allow"
      rules = [
        {
          name                  = "AllowHTTPS"
          source_addresses      = ["*"]
          destination_addresses = ["*"]
          destination_ports     = ["443"]
          protocols             = ["TCP"]
        }
      ]
    }
  ]

  # Application rules (FQDN filtering)
  application_rule_collections = [
    {
      name     = "AllowMicrosoftServices"
      priority = 100
      action   = "Allow"
      rules = [
        {
          name             = "AllowWindowsUpdate"
          source_addresses = ["*"]
          fqdn_tags        = ["WindowsUpdate"]
        },
        {
          name             = "AllowAzureServices"
          source_addresses = ["*"]
          target_fqdns     = ["*.azure.com", "*.microsoft.com"]
        }
      ]
    }
  ]

  # NAT rules (DNAT - Destination NAT)
  nat_rule_collections = []

  # Tags
  tags = {
    Environment = "stage"
    Component   = "firewall"
  }
}

