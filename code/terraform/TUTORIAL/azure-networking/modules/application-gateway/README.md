# Azure Application Gateway Module

This module creates an Azure Application Gateway with Web Application Firewall (WAF) support.

## Features

- Layer 7 (HTTP/HTTPS) load balancing
- SSL/TLS termination
- Web Application Firewall (WAF) protection
- URL-based routing
- Multi-site hosting
- Session affinity
- HTTP to HTTPS redirection
- Autoscaling (v2 SKU)
- Zone redundancy (v2 SKU)

## Usage

```hcl
module "app_gateway" {
  source = "./modules/application-gateway"
  
  resource_group_name = "rg-example"
  location            = "eastus"
  application_gateway_name = "appgw-main"
  
  sku_name     = "WAF_v2"
  sku_tier     = "WAF_v2"
  sku_capacity = null  # Autoscaling
  
  autoscale_configuration = {
    min_capacity = 2
    max_capacity = 10
  }
  
  gateway_ip_configuration = {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.appgw.id
  }
  
  frontend_ip_configurations = [
    {
      name                 = "public-frontend"
      public_ip_address_id = azurerm_public_ip.appgw.id
    }
  ]
  
  frontend_ports = [
    {
      name = "http-port"
      port = 80
    }
  ]
  
  backend_address_pools = [
    {
      name         = "web-backend"
      ip_addresses = ["10.0.2.10", "10.0.2.11"]
      fqdns        = []
    }
  ]
  
  backend_http_settings = [
    {
      name                                = "http-setting"
      cookie_based_affinity               = "Disabled"
      path                                = "/"
      port                                = 80
      protocol                            = "Http"
      request_timeout                     = 20
      probe_name                          = "http-probe"
      pick_host_name_from_backend_address = true
    }
  ]
  
  http_listeners = [
    {
      name                           = "http-listener"
      frontend_ip_configuration_name = "public-frontend"
      frontend_port_name             = "http-port"
      protocol                       = "Http"
    }
  ]
  
  request_routing_rules = [
    {
      name                        = "http-rule"
      rule_type                   = "Basic"
      http_listener_name          = "http-listener"
      backend_address_pool_name   = "web-backend"
      backend_http_settings_name  = "http-setting"
    }
  ]
  
  probes = [
    {
      name                                      = "http-probe"
      protocol                                  = "Http"
      path                                      = "/health"
      interval                                  = 30
      timeout                                   = 30
      unhealthy_threshold                       = 3
      pick_host_name_from_backend_http_settings = true
      match = {
        status_codes = ["200-399"]
      }
    }
  ]
  
  waf_configuration = {
    enabled                  = true
    firewall_mode            = "Prevention"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.2"
  }
}
```

## Requirements

- Dedicated subnet for Application Gateway (minimum /24 for v1, /26 for v2)
- Public IP address (for internet-facing gateway)
- Backend servers configured

## Outputs

- `application_gateway_id`: The ID of the Application Gateway
- `application_gateway_fqdn`: The FQDN of the Application Gateway
- `public_ip_address`: The public IP address
- `backend_address_pool_ids`: Map of backend pool names to IDs

