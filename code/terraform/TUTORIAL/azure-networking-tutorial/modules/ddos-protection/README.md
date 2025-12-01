# Azure DDoS Protection Module

This module creates a DDoS Protection Plan to protect Azure resources from DDoS attacks.

## Features

- Basic tier: Always-on protection (free)
- Standard tier: Advanced features with attack analytics
- Automatic mitigation
- Cost protection (Standard tier)
- DDoS rapid response support (Standard tier)

## Usage

```hcl
module "ddos_protection" {
  source = "./modules/ddos-protection"
  
  resource_group_name = "rg-example"
  location           = "eastus"
  
  ddos_protection_plan_name = "ddos-plan-prod"
  sku                      = "Standard"  # or "Basic" for free tier
}
```

## Requirements

- Virtual Networks must be associated with the DDoS Protection Plan at the VNet level

## Outputs

- `ddos_protection_plan_id`: The ID of the DDoS Protection Plan
- `ddos_protection_plan_name`: The name of the DDoS Protection Plan

