# ============================================================================
# TERRAGRUNT CONFIGURATION: Azure Firewall (Production Environment)
# ============================================================================
# Production firewall with enhanced security rules and monitoring.
# ============================================================================

terraform {
  source = "../../../../modules//firewall"
}

include {
  path = find_in_parent_folders()
}

dependency "vnet" {
  config_path = "../networking/vnet"

  mock_outputs = {
    vnet_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-networking-prod/providers/Microsoft.Network/virtualNetworks/vnet-prod"
    subnet_ids = {}
  }

  skip_outputs = false
}

inputs = {
  resource_group_name = "rg-networking-prod"
  location           = "eastus"
  firewall_name      = "fw-prod"

  # Production: Use Premium SKU for advanced features
  sku_name         = "AZFW_VNet"
  sku_tier         = "Premium"  # Premium for TLS inspection, IDPS, etc.
  firewall_policy_id = null  # Optional: Use Firewall Manager for centralized policies

  subnet_id = dependency.vnet.outputs.subnet_ids["firewall-subnet"]

  # Production: Multiple public IPs for high availability
  public_ip_count = 2

  # Production network rules (more restrictive)
  network_rule_collections = [
    {
      name     = "AllowOutboundHTTPS"
      priority = 100
      action   = "Allow"
      rules = [
        {
          name                  = "AllowHTTPS"
          source_addresses      = ["10.0.0.0/16"]
          destination_addresses = ["*"]
          destination_ports     = ["443"]
          protocols             = ["TCP"]
        }
      ]
    }
  ]

  # Production application rules
  application_rule_collections = [
    {
      name     = "AllowMicrosoftServices"
      priority = 100
      action   = "Allow"
      rules = [
        {
          name             = "AllowWindowsUpdate"
          source_addresses = ["10.0.0.0/16"]
          fqdn_tags        = ["WindowsUpdate"]
        }
      ]
    }
  ]

  # Production: Enable threat intelligence
  threat_intelligence_mode = "Deny"  # "Off", "Alert", "Deny"

  tags = {
    Environment = "production"
    Component   = "firewall"
    ManagedBy   = "Terragrunt"
  }
}

