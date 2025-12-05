# Azure Firewall Module

This module creates an Azure Firewall with network rules, application rules, and NAT rules.

## Features

- Network rules (Layer 3/4 filtering)
- Application rules (FQDN-based filtering)
- NAT rules (DNAT - Destination NAT)
- Threat Intelligence filtering
- Built-in high availability
- Auto-scaling
- Forced tunneling support
- DNS proxy support

## Usage

```hcl
module "firewall" {
  source = "./modules/firewall"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  firewall_name        = "fw-main"
  
  # Dedicated subnet for Firewall (minimum /26)
  subnet_id = azurerm_subnet.firewall.id
  
  # Public IP for Firewall
  public_ip_allocation_method = "Static"
  public_ip_sku               = "Standard"
  
  sku_name = "AZFW_VNet"  # or "AZFW_Hub" for Virtual WAN
  sku_tier = "Standard"   # or "Premium"
  
  # Network Rules
  network_rule_collections = [
    {
      name     = "AllowHTTPS"
      priority = 100
      action   = "Allow"
      rules = [
        {
          name                  = "AllowHTTPS"
          protocols             = ["TCP"]
          source_addresses      = ["10.0.0.0/16"]
          destination_addresses = ["*"]
          destination_ports     = ["443"]
        }
      ]
    }
  ]
  
  # Application Rules
  application_rule_collections = [
    {
      name     = "AllowMicrosoft"
      priority = 200
      action   = "Allow"
      rules = [
        {
          name             = "AllowMicrosoft"
          source_addresses = ["10.0.0.0/16"]
          target_fqdns     = ["*.microsoft.com"]
          protocols = [
            {
              type = "Https"
              port = "443"
            }
          ]
        }
      ]
    }
  ]
  
  # NAT Rules (DNAT)
  nat_rule_collections = [
    {
      name     = "DNAT-WebServer"
      priority = 300
      action   = "Dnat"
      rules = [
        {
          name                = "DNAT-WebServer"
          protocols           = ["TCP"]
          source_addresses   = ["*"]
          destination_address = azurerm_public_ip.firewall.ip_address
          destination_ports   = ["80"]
          translated_address  = "10.0.2.10"
          translated_port     = "80"
        }
      ]
    }
  ]
  
  # Threat Intelligence
  threat_intelligence_mode = "Alert"  # "Off", "Alert", "Deny"
  
  tags = {
    Environment = "Production"
  }
}
```

## Requirements

- Dedicated subnet for Firewall (minimum /26 CIDR, named 'AzureFirewallSubnet')
- Public IP address (Standard SKU)
- Route table to direct traffic through Firewall (optional)

## Outputs

- `firewall_id`: The ID of the Azure Firewall
- `firewall_name`: The name of the Azure Firewall
- `public_ip_address`: The public IP address of the Firewall
- `private_ip_address`: The private IP address of the Firewall

