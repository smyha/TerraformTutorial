# Azure Load Balancer Module

This module creates an Azure Load Balancer (Standard SKU) for distributing incoming and outgoing traffic.

## Features

- Layer 4 (TCP/UDP) load balancing
- High availability by distributing traffic
- Health probes to detect unhealthy backends
- Load balancing rules for inbound traffic
- Outbound rules for outbound traffic (NAT)
- Support for both public and internal load balancers
- Zone redundancy (Standard SKU)

## Usage

```hcl
module "load_balancer" {
  source = "./modules/load-balancer"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  load_balancer_name  = "lb-main"
  
  sku      = "Standard"
  sku_tier = "Regional"
  
  frontend_ip_configurations = [
    {
      name                 = "public-frontend"
      public_ip_address_id = azurerm_public_ip.lb.id
    }
  ]
  
  backend_address_pools = [
    {
      name = "web-backend"
    }
  ]
  
  probes = [
    {
      name                = "http-probe"
      protocol            = "Http"
      port                = 80
      path                = "/health"
      interval_in_seconds = 5
      number_of_probes    = 2
    }
  ]
  
  load_balancing_rules = [
    {
      name                           = "http-rule"
      protocol                       = "Tcp"
      frontend_port                  = 80
      backend_port                   = 80
      frontend_ip_configuration_name = "public-frontend"
      backend_address_pool_name     = "web-backend"
      probe_name                     = "http-probe"
      idle_timeout_in_minutes        = 4
      load_distribution              = "Default"  # "Default", "SourceIP", "SourceIPProtocol"
    }
  ]
  
  # Optional: Outbound rules for SNAT
  outbound_rules = [
    {
      name                           = "outbound-rule"
      protocol                       = "All"
      frontend_ip_configuration_name = "public-frontend"
      backend_address_pool_name     = "web-backend"
      allocated_outbound_ports      = 1024
      idle_timeout_in_minutes        = 4
    }
  ]
  
  tags = {
    Environment = "Production"
  }
}
```

## Requirements

- Public IP address (for public load balancer) or subnet (for internal load balancer)
- Backend VMs or VM scale sets

## Outputs

- `load_balancer_id`: The ID of the Load Balancer
- `load_balancer_name`: The name of the Load Balancer
- `frontend_ip_configuration`: Map of frontend IP configuration names to IP addresses
- `backend_address_pool_ids`: Map of backend pool names to IDs

