# Azure Bastion Module

This module creates an Azure Bastion host for secure RDP/SSH access to VMs without public IPs.

## Features

- Browser-based RDP/SSH access
- No public IPs required on VMs
- No VPN required
- All traffic encrypted (HTTPS)
- NSG integration
- Native Azure Portal integration
- IP-based and hostname-based connections

## Usage

```hcl
module "bastion" {
  source = "./modules/bastion"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  bastion_name        = "bastion-main"
  
  # Dedicated subnet for Bastion (minimum /26)
  subnet_id = azurerm_subnet.bastion.id
  
  # Public IP for Bastion
  public_ip_allocation_method = "Static"
  public_ip_sku               = "Standard"
  
  # Optional: IP-based connection
  ip_connect_enabled = true
  
  # Optional: Scale units (2-50)
  scale_units = 2
  
  tags = {
    Environment = "Production"
  }
}
```

## Requirements

- Dedicated subnet for Bastion (minimum /26 CIDR, named 'AzureBastionSubnet')
- Public IP address (Standard SKU)
- VMs must be in the same VNet or peered VNet

## Outputs

- `bastion_id`: The ID of the Bastion host
- `bastion_name`: The name of the Bastion host
- `public_ip_address`: The public IP address of the Bastion host
- `dns_name`: The DNS name of the Bastion host

