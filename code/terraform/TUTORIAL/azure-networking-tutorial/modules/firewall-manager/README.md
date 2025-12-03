# Azure Firewall Manager Module

This module creates a Firewall Policy for centralized security management across multiple Azure Firewalls.

## Features

- Centralized firewall policy management
- Rule collection groups
- Threat Intelligence integration
- DNS settings
- TLS inspection (Premium SKU)
- Network, Application, and NAT rule collections

## Usage

```hcl
module "firewall_manager" {
  source = "./modules/firewall-manager"
  
  resource_group_name = "rg-example"
  location           = "eastus"
  
  firewall_policy_name = "fw-policy-central"
  sku                 = "Premium"
  
  threat_intelligence_mode = "Deny"
  
  rule_collection_groups = {
    "network-rules" = {
      priority = 100
      network_rule_collections = [
        {
          name     = "AllowHTTPS"
          priority = 100
          action   = "Allow"
          rules = [
            {
              name                  = "AllowHTTPS"
              protocols             = ["TCP"]
              source_addresses      = ["*"]
              destination_addresses = ["*"]
              destination_ports     = ["443"]
            }
          ]
        }
      ]
    }
  }
}
```

## Outputs

- `firewall_policy_id`: The ID of the Firewall Policy
- `firewall_policy_name`: The name of the Firewall Policy
- `rule_collection_group_ids`: Map of rule collection group names to IDs

