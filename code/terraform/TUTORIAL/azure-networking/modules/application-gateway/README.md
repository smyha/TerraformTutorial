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

- **Dedicated Subnet**: Application Gateway requires a dedicated subnet (no other resources)
  - **V1 SKU**: Minimum /24 subnet (256 IPs)
  - **V2 SKU**: Minimum /26 subnet (64 IPs) - recommended
  - **Subnet Sizing Guidelines**:
    - `/28` subnet: Supports up to 4 instances
    - `/27` subnet: Supports up to 8 instances
    - `/26` subnet: Supports up to 16 instances
    - Plan subnet size based on expected scaling requirements
- **Public IP Address**: Required for internet-facing gateway (optional for internal-only)
- **Backend Servers**: Configure backend pools with healthy servers

## Best Practices

Based on Azure Application Gateway documentation:

### SKU Selection
- **Use V2 SKU**: Standard_v2 or WAF_v2 (recommended)
  - Autoscaling support
  - Zone redundancy
  - Performance improvements
  - Better cost optimization
- **WAF Tier**: Use WAF_v2 for production web applications requiring security
  - OWASP Core Rule Set (CRS) 3.0 or 3.2 (recommended)
  - Protection against SQL injection, XSS, and other web vulnerabilities

### Scaling Configuration
- **Autoscaling (V2)**: Recommended for cost optimization
  - Set appropriate min/max capacity based on traffic patterns
  - Automatically scales based on application traffic
- **Manual Scaling**: Only when you need fixed capacity
  - Specify exact instance count
  - Requires manual adjustment for traffic changes

### Network Configuration
- **Subnet Planning**: Size subnet based on maximum expected instances
  - Example: If planning to scale to 4 instances, use /28 subnet
  - Application Gateway uses private IPs for internal communication
  - Additional IPs needed for each instance when scaling
- **Zone Redundancy**: Enable for high availability (V2 SKU)
  - Deploy across availability zones
  - Provides protection against zone-level failures

### Health Probes
- **Dedicated Endpoint**: Use a dedicated health check endpoint (e.g., `/health`)
- **Lightweight**: Keep health checks fast and lightweight
- **Appropriate Interval**: Balance between responsiveness and overhead
  - Default: 30 seconds
  - Faster: 10 seconds for critical applications
  - Slower: 60 seconds to reduce probe load
- **Status Codes**: Configure appropriate healthy status code ranges (200-399 default)

### Security
- **HTTPS**: Enable HTTPS listeners with SSL certificates
- **WAF Mode**: Use Prevention mode for production (Detection for testing)
- **SSL Termination**: Offload SSL processing from backend servers
- **End-to-End Encryption**: Consider encrypting traffic from gateway to backend

### Load Balancing
- **Round-Robin**: Default algorithm distributes requests evenly
- **Session Affinity**: Enable only when required for stateful applications
  - Use cookie-based affinity
  - Disable when not needed for better load distribution
- **Connection Draining**: Enable for graceful server removal
  - Allows in-flight requests to complete before removing server
  - Prevents user impact during maintenance

### Routing
- **Path-Based Routing**: Route different paths to specialized backend pools
- **Multiple Site Hosting**: Host multiple websites on one gateway
- **HTTP to HTTPS Redirection**: Automatically redirect insecure traffic

## Outputs

- `application_gateway_id`: The ID of the Application Gateway
- `application_gateway_fqdn`: The FQDN of the Application Gateway
- `public_ip_address`: The public IP address
- `backend_address_pool_ids`: Map of backend pool names to IDs

