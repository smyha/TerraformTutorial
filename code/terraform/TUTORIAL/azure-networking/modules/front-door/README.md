# Azure Front Door Module

This module creates an Azure Front Door (classic) instance for global application delivery.

## Features

- **Global Load Balancing**: Distributes traffic across multiple Azure regions and on-premises locations
- **WAF Protection**: Web Application Firewall integration for security
- **SSL/TLS Termination**: Handles SSL/TLS at the edge
- **Edge Caching**: Content caching at edge locations worldwide
- **URL Rewrite/Redirect**: Path rewriting and HTTP to HTTPS redirection
- **Health Probes**: Automatic health monitoring of backend servers
- **Session Affinity**: Sticky sessions for stateful applications

## Usage

### Basic Example

```hcl
module "front_door" {
  source = "./modules/front-door"
  
  resource_group_name = "rg-example"
  location            = "global"  # Note: Front Door is global, location is for consistency only
  
  front_door_name = "fd-global-app"
  friendly_name   = "Global Application Front Door"
  
  # Backend Pool Health Probes
  backend_pool_health_probes = [
    {
      name                = "http-probe"
      protocol            = "Http"
      path                = "/health"
      interval_in_seconds = 30
      enabled             = true
    }
  ]
  
  # Backend Pool Load Balancing Settings
  backend_pool_load_balancing = [
    {
      name                            = "lb-settings"
      sample_size                     = 4
      successful_samples_required     = 2
      additional_latency_milliseconds = 0
    }
  ]
  
  # Backend Pools
  backend_pools = [
    {
      name                = "web-backend"
      health_probe_name   = "http-probe"
      load_balancing_name = "lb-settings"
      backends = [
        {
          host_header = "www.example.com"
          address     = "10.0.1.10"
          http_port   = 80
          https_port  = 443
          priority    = 1
          weight      = 50
          enabled     = true
        }
      ]
    }
  ]
  
  # Frontend Endpoints
  frontend_endpoints = [
    {
      name      = "www-endpoint"
      host_name = "www.example.com"
      session_affinity_enabled = false
      session_affinity_ttl_seconds = 0
      web_application_firewall_policy_link_id = null
    }
  ]
  
  # Routing Rules
  routing_rules = [
    {
      name               = "http-rule"
      frontend_endpoints  = ["www-endpoint"]
      accepted_protocols  = ["Http", "Https"]
      patterns_to_match   = ["/*"]
      enabled            = true
      route_configuration = {
        forwarding_protocol = "MatchRequest"
        backend_pool_name   = "web-backend"
        cache_enabled       = false
      }
    }
  ]
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Example with Redirect

```hcl
routing_rules = [
  {
    name               = "redirect-rule"
    frontend_endpoints  = ["www-endpoint"]
    accepted_protocols  = ["Http"]
    patterns_to_match   = ["/*"]
    enabled            = true
    route_configuration = {
      redirect_type     = "Moved"
      redirect_protocol = "HttpsOnly"
      redirect_host     = "www.example.com"
      redirect_path     = "/{path}"
      redirect_query_string = "{query}"
    }
  }
]
```

## Best Practices

### 1. Health Probes
- Configure health probes for all backend pools
- Use appropriate probe intervals (30-60 seconds recommended)
- Set up health probe paths that accurately reflect backend health
- Monitor health probe success rates

### 2. Load Balancing
- Configure appropriate sample sizes for load balancing decisions
- Balance between latency and accuracy in load balancing settings
- Use priority-based routing for failover scenarios

### 3. Caching
- Enable caching for static content (images, CSS, JS)
- Disable caching for dynamic content (APIs, user-specific content)
- Configure appropriate cache durations based on content type
- Use cache query parameter strip directives appropriately

### 4. Security
- Enable WAF policies on frontend endpoints
- Use HTTPS-only protocols where possible
- Configure redirect rules to force HTTPS
- Implement proper SSL/TLS certificate management

### 5. Routing
- Use specific path patterns before general patterns
- Configure appropriate forwarding protocols
- Use custom forwarding paths for URL rewriting
- Implement proper redirect configurations

### 6. Backend Configuration
- Configure multiple backends for high availability
- Use appropriate priority and weight settings
- Enable/disable backends based on deployment needs
- Configure proper host headers for backend communication

## Outputs

- `front_door_id`: The ID of the Front Door resource
- `front_door_name`: The name of the Front Door
- `frontend_endpoint_hostnames`: Map of frontend endpoint names to their hostnames
- `cname`: The CNAME of the Front Door (for DNS configuration)

## Important Notes

- **Front Door Name**: Must be globally unique across all Azure Front Door instances
- **Location**: Front Door is a global service. The `location` variable is kept for consistency but is not used in the resource.
- **Classic vs Standard/Premium**: This module uses the classic Front Door resource (`azurerm_frontdoor`). For Standard/Premium tiers, use `azurerm_cdn_frontdoor_profile` and related resources.
- **WAF**: Web Application Firewall policies must be created separately and linked via `web_application_firewall_policy_link_id`

