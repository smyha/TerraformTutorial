# ============================================================================
# Azure Application Gateway Module - Main Configuration
# ============================================================================
# Application Gateway is a web traffic load balancer that operates at Layer 7
# (HTTP/HTTPS). It provides advanced routing capabilities and WAF protection.
#
# Architecture:
# Internet/Client
#     ↓
# Public IP (Application Gateway)
#     ↓
# Application Gateway (Layer 7)
#     ├── WAF (if enabled)
#     ├── SSL/TLS Termination
#     ├── URL-based Routing
#     ├── Host-based Routing
#     └── Session Affinity
#     ↓
# Backend Pool (Web Servers)
# ============================================================================

# ----------------------------------------------------------------------------
# Public IP for Application Gateway
# ----------------------------------------------------------------------------
# Application Gateway requires a public IP address for internet-facing traffic.
# For internal Application Gateway, use a private IP instead.
# ----------------------------------------------------------------------------
resource "azurerm_public_ip" "main" {
  count = var.public_ip_enabled ? 1 : 0
  
  name                = "${var.application_gateway_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  zones               = var.zones
  domain_name_label   = var.public_ip_domain_name_label
  
  tags = var.tags
}

# ----------------------------------------------------------------------------
# Application Gateway
# ----------------------------------------------------------------------------
# Application Gateway provides:
# - Layer 7 (HTTP/HTTPS) load balancing
# - SSL/TLS termination
# - Web Application Firewall (WAF) protection
# - URL-based routing
# - Multi-site hosting
# - Session affinity
# - HTTP to HTTPS redirection
#
# SKU Options:
# - Standard: Basic features, fixed capacity
# - Standard_v2: Autoscaling, zone redundancy
# - WAF: Standard + WAF protection
# - WAF_v2: Standard_v2 + WAF protection (recommended)
#
# Subnet Requirements:
# - Dedicated subnet (no other resources)
# - Minimum /24 CIDR (256 IP addresses)
# - For v2 SKU: /26 minimum (64 IP addresses)
# ----------------------------------------------------------------------------
resource "azurerm_application_gateway" "main" {
  name                = var.application_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  # SKU Configuration
  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.sku_capacity  # null for autoscaling (v2 only)
  }
  
  # Autoscale Configuration (v2 SKU only)
  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration != null ? [var.autoscale_configuration] : []
    content {
      min_capacity = autoscale_configuration.value.min_capacity
      max_capacity = autoscale_configuration.value.max_capacity
    }
  }
  
  # Gateway IP Configuration (Subnet)
  gateway_ip_configuration {
    name      = var.gateway_ip_configuration.name
    subnet_id = var.gateway_ip_configuration.subnet_id
  }
  
  # Frontend IP Configuration
  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations
    content {
      name                 = frontend_ip_configuration.value.name
      public_ip_address_id = frontend_ip_configuration.value.public_ip_address_id
      private_ip_address   = frontend_ip_configuration.value.private_ip_address
      subnet_id            = frontend_ip_configuration.value.subnet_id
    }
  }
  
  # Frontend Ports
  dynamic "frontend_port" {
    for_each = var.frontend_ports
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }
  
  # Backend Address Pools
  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = backend_address_pool.value.name
      ip_addresses = backend_address_pool.value.ip_addresses
      fqdns        = backend_address_pool.value.fqdns
    }
  }
  
  # Backend HTTP Settings
  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      affinity_cookie_name                = backend_http_settings.value.affinity_cookie_name
      path                                = backend_http_settings.value.path
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      probe_name                          = backend_http_settings.value.probe_name
      host_name                           = backend_http_settings.value.host_name
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
      
      # Authentication Certificate (for mutual TLS)
      dynamic "authentication_certificate" {
        for_each = backend_http_settings.value.authentication_certificate != null ? [backend_http_settings.value.authentication_certificate] : []
        content {
          name = authentication_certificate.value.name
        }
      }
      
      # Connection Draining
      connection_draining {
        enabled           = backend_http_settings.value.connection_draining != null ? backend_http_settings.value.connection_draining.enabled : false
        drain_timeout_sec = backend_http_settings.value.connection_draining != null ? backend_http_settings.value.connection_draining.drain_timeout_sec : 1
      }
    }
  }
  
  # HTTP Listeners
  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      host_name                      = http_listener.value.host_name
      host_names                     = http_listener.value.host_names
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
      firewall_policy_id             = http_listener.value.firewall_policy_id
      require_sni                    = http_listener.value.require_sni
    }
  }
  
  # Request Routing Rules
  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      name                        = request_routing_rule.value.name
      rule_type                   = request_routing_rule.value.rule_type
      http_listener_name          = request_routing_rule.value.http_listener_name
      backend_address_pool_name   = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name  = request_routing_rule.value.backend_http_settings_name
      redirect_configuration_name = request_routing_rule.value.redirect_configuration_name
      rewrite_rule_set_name       = request_routing_rule.value.rewrite_rule_set_name
      url_path_map_name           = request_routing_rule.value.url_path_map_name
      priority                    = request_routing_rule.value.priority
    }
  }
  
  # Probes (Health Checks)
  dynamic "probe" {
    for_each = var.probes
    content {
      name                                      = probe.value.name
      protocol                                  = probe.value.protocol
      host                                      = probe.value.host
      path                                      = probe.value.path
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
      minimum_servers                           = probe.value.minimum_servers
      
      # Match Configuration
      dynamic "match" {
        for_each = probe.value.match != null ? [probe.value.match] : []
        content {
          body        = match.value.body
          status_code = match.value.status_code
        }
      }
    }
  }
  
  # SSL Certificates
  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name                = ssl_certificate.value.name
      data                = ssl_certificate.value.data
      password            = ssl_certificate.value.password
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }
  }
  
  # Web Application Firewall Configuration (WAF SKU only)
  dynamic "waf_configuration" {
    for_each = var.waf_configuration != null ? [var.waf_configuration] : []
    content {
      enabled                  = waf_configuration.value.enabled
      firewall_mode            = waf_configuration.value.firewall_mode
      rule_set_type            = waf_configuration.value.rule_set_type
      rule_set_version         = waf_configuration.value.rule_set_version
      file_upload_limit_mb     = waf_configuration.value.file_upload_limit_mb
      request_body_check       = waf_configuration.value.request_body_check
      max_request_body_size_kb = waf_configuration.value.max_request_body_size_kb
      
      # Disabled Rule Groups
      dynamic "disabled_rule_group" {
        for_each = waf_configuration.value.disabled_rule_groups != null ? waf_configuration.value.disabled_rule_groups : []
        content {
          rule_group_name = disabled_rule_group.value.rule_group_name
          rules           = disabled_rule_group.value.rules
        }
      }
      
      # Exclusion Rules
      dynamic "exclusion" {
        for_each = waf_configuration.value.exclusions != null ? waf_configuration.value.exclusions : []
        content {
          match_variable          = exclusion.value.match_variable
          selector_match_operator = exclusion.value.selector_match_operator
          selector                = exclusion.value.selector
        }
      }
    }
  }
  
  # Identity (for Key Vault integration)
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
  
  # Zones (for zone redundancy)
  zones = var.zones
  
  tags = var.tags
}

