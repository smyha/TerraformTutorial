# ============================================================================
# Azure Application Gateway Module - Variables
# ============================================================================
# Application Gateway is a web traffic load balancer that enables you to
# manage traffic to your web applications. It operates at Layer 7 (HTTP/HTTPS).
#
# Key Features:
# - Layer 7 load balancing
# - SSL/TLS termination
# - Web Application Firewall (WAF)
# - URL-based routing
# - Multi-site hosting
# - Session affinity
# - Redirection (HTTP to HTTPS)
# ============================================================================

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "application_gateway_name" {
  description = "Name of the Application Gateway"
  type        = string
}

/**
* SKU name is the name of the SKU of the Application Gateway.
* It is used to specify the SKU of the Application Gateway.
* The SKU is the name of the SKU of the Application Gateway.
*/
variable "sku_name" {
  description = "SKU name. Options: 'Standard_Small', 'Standard_Medium', 'Standard_Large', 'Standard_v2', 'WAF_Medium', 'WAF_Large', 'WAF_v2'"
  type        = string
  default     = "Standard_v2"
}

/**
* SKU tier is the tier of the SKU of the Application Gateway.
* It is used to specify the tier of the SKU of the Application Gateway.
* The tier is the tier of the SKU of the Application Gateway.
*/
variable "sku_tier" {
  description = "SKU tier. Options: 'Standard', 'Standard_v2', 'WAF', 'WAF_v2'"
  type        = string
  default     = "Standard_v2"
  
  validation {
    condition     = contains(["Standard", "Standard_v2", "WAF", "WAF_v2"], var.sku_tier)
    error_message = "SKU tier must be one of: Standard, Standard_v2, WAF, WAF_v2."
  }
}

/**
* SKU capacity is the capacity of the SKU of the Application Gateway.
* It is used to specify the capacity of the SKU of the Application Gateway.
* The capacity is the capacity of the SKU of the Application Gateway.
*/
variable "sku_capacity" {
  description = "Number of instances (1-125). For autoscaling, set to null."
  type        = number
  default     = 2
  
  validation {
    condition     = var.sku_capacity == null || (var.sku_capacity >= 1 && var.sku_capacity <= 125)
    error_message = "SKU capacity must be between 1 and 125, or null for autoscaling."
  }
}

variable "autoscale_configuration" {
  description = <<-EOT
    Autoscale configuration (only for v2 SKU).
    Example:
    autoscale_configuration = {
      min_capacity = 2
      max_capacity = 10
    }
  EOT
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}

variable "zones" {
  description = "Availability zones. v2 SKU supports all zones for zone redundancy."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "gateway_ip_configuration" {
  description = <<-EOT
    Gateway IP configuration (subnet for Application Gateway).
    The subnet must be dedicated to Application Gateway (no other resources).
    Minimum size: /24
  EOT
  type = object({
    name      = string
    subnet_id = string
  })
}

variable "frontend_ip_configurations" {
  description = <<-EOT
    List of frontend IP configurations.
    Can be public (public IP) or private (subnet IP).
    
    Example:
    frontend_ip_configurations = [
      {
        name                 = "public-frontend"
        public_ip_address_id = azurerm_public_ip.appgw.id
      },
      {
        name                          = "private-frontend"
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.0.1.100"
        subnet_id                    = azurerm_subnet.appgw.id
      }
    ]
  EOT
  type = list(object({
    name                          = string
    public_ip_address_id          = optional(string, null)
    private_ip_address_allocation = optional(string, null) # "Static" or "Dynamic"
    private_ip_address            = optional(string, null)
    subnet_id                     = optional(string, null)
  }))
}

variable "backend_address_pools" {
  description = <<-EOT
    List of backend address pools.
    Backend pools contain the servers that will receive traffic.
    
    Example:
    backend_address_pools = [
      {
        name         = "web-backend"
        ip_addresses = ["10.0.2.10", "10.0.2.11"]
        fqdns        = []
      },
      {
        name         = "api-backend"
        ip_addresses = []
        fqdns        = ["api.example.com"]
      }
    ]
  EOT
  type = list(object({
    name         = string
    ip_addresses = list(string)
    fqdns        = list(string)
  }))
  
  default = []
}

variable "backend_http_settings" {
  description = <<-EOT
    List of backend HTTP settings.
    Defines how Application Gateway communicates with backend servers.
    
    Example:
    backend_http_settings = [
      {
        name                                = "http-setting"
        cookie_based_affinity               = "Disabled"
        path                                = "/"
        port                                = 80
        protocol                            = "Http"
        request_timeout                     = 20
        probe_name                          = "http-probe"
        host_name                           = null
        pick_host_name_from_backend_address = true
        affinity_cookie_name                = null
      }
    ]
  EOT
  type = list(object({
    name                                = string
    cookie_based_affinity               = string # "Enabled" or "Disabled"
    path                                = string
    port                                = number
    protocol                            = string # "Http" or "Https"
    request_timeout                     = number
    probe_name                          = optional(string, null)
    host_name                           = optional(string, null)
    pick_host_name_from_backend_address = optional(bool, false)
    affinity_cookie_name                = optional(string, null)
  }))
  
  default = []
}

variable "http_listeners" {
  description = <<-EOT
    List of HTTP listeners.
    Listeners define how Application Gateway receives traffic.
    
    Example:
    http_listeners = [
      {
        name                           = "http-listener"
        frontend_ip_configuration_name = "public-frontend"
        frontend_port_name             = "http-port"
        protocol                       = "Http"
        host_name                      = null
        require_sni                    = false
        ssl_certificate_name           = null
      },
      {
        name                           = "https-listener"
        frontend_ip_configuration_name = "public-frontend"
        frontend_port_name             = "https-port"
        protocol                       = "Https"
        host_name                      = "www.example.com"
        require_sni                    = true
        ssl_certificate_name           = "ssl-cert"
      }
    ]
  EOT
  type = list(object({
    name                           = string
    frontend_ip_configuration_name = string
    frontend_port_name             = string
    protocol                       = string # "Http" or "Https"
    host_name                      = optional(string, null)
    require_sni                    = optional(bool, false)
    ssl_certificate_name           = optional(string, null)
  }))
  
  default = []
}

variable "request_routing_rules" {
  description = <<-EOT
    List of request routing rules.
    Rules define how traffic is routed to backend pools.
    
    Routing types:
    - Basic: Route all traffic to a single backend pool
    - Path-based: Route based on URL path
    - Multi-site: Route based on host header
    
    Example:
    request_routing_rules = [
      {
        name                        = "http-rule"
        rule_type                   = "Basic"
        http_listener_name          = "http-listener"
        backend_address_pool_name   = "web-backend"
        backend_http_settings_name  = "http-setting"
        url_path_map_name           = null
        redirect_configuration_name = null
      },
      {
        name                        = "path-based-rule"
        rule_type                   = "PathBasedRouting"
        http_listener_name          = "https-listener"
        backend_address_pool_name   = null
        backend_http_settings_name  = null
        url_path_map_name           = "url-path-map"
        redirect_configuration_name = null
      }
    ]
  EOT
  type = list(object({
    name                        = string
    rule_type                   = string # "Basic", "PathBasedRouting", "MultiSite"
    http_listener_name          = string
    backend_address_pool_name   = optional(string, null)
    backend_http_settings_name  = optional(string, null)
    url_path_map_name           = optional(string, null)
    redirect_configuration_name = optional(string, null)
  }))
  
  default = []
}

variable "probes" {
  description = <<-EOT
    List of health probes.
    Probes check the health of backend servers.
    
    Example:
    probes = [
      {
        name                                      = "http-probe"
        protocol                                  = "Http"
        path                                      = "/health"
        host                                      = null
        interval                                  = 30
        timeout                                   = 30
        unhealthy_threshold                        = 3
        pick_host_name_from_backend_http_settings = true
        minimum_servers                            = 0
        match = {
          status_codes = ["200-399"]
          body         = null
        }
      }
    ]
  EOT
  type = list(object({
    name                                      = string
    protocol                                  = string # "Http" or "Https"
    path                                      = string
    host                                      = optional(string, null)
    interval                                  = number
    timeout                                   = number
    unhealthy_threshold                       = number
    pick_host_name_from_backend_http_settings = optional(bool, true)
    minimum_servers                           = optional(number, 0)
    match = object({
      status_codes = list(string)
      body         = optional(string, null)
    })
  }))
  
  default = []
}

variable "ssl_certificates" {
  description = <<-EOT
    List of SSL certificates.
    Certificates are used for HTTPS listeners.
    
    Example:
    ssl_certificates = [
      {
        name                = "ssl-cert"
        key_vault_secret_id = null
        data                = filebase64("certificate.pfx")
        password            = "cert-password"
      }
    ]
  EOT
  type = list(object({
    name                = string
    key_vault_secret_id = optional(string, null)
    data                = optional(string, null) # Base64 encoded PFX
    password            = optional(string, null) # PFX password
  }))
  
  default = []
}

/**
* WAF configuration is a feature of the Application Gateway that allows you to configure the Web Application Firewall (WAF) for the Application Gateway.
* It is used to protect your web applications from common vulnerabilities and exploits.
*/
variable "waf_configuration" {
  description = <<-EOT
    WAF configuration (only for WAF SKU).
    Example:
    waf_configuration = {
      enabled                  = true
      firewall_mode            = "Detection" # "Detection" or "Prevention"
      rule_set_type            = "OWASP"
      rule_set_version         = "3.2"
      file_upload_limit_mb     = 100
      max_request_body_size_kb  = 128
      request_body_check        = true
    }
  EOT
  type = object({
    enabled                  = bool
    firewall_mode            = string # "Detection" or "Prevention"
    rule_set_type            = string # "OWASP"
    rule_set_version         = string # "3.0", "3.1", "3.2"
    file_upload_limit_mb     = optional(number, 100)
    max_request_body_size_kb = optional(number, 128)
    request_body_check       = optional(bool, true)
  })
  default = null
}

variable "tags" {
  description = "Map of tags"
  type        = map(string)
  default     = {}
}

