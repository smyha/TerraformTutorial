# ============================================================================
# Azure Front Door Module - Main Configuration
# ============================================================================
# Azure Front Door is a global, scalable entry point that provides:
# - Global load balancing
# - WAF protection
# - SSL/TLS termination
# - Edge caching
# - URL rewrite
#
# Architecture:
# Global Users
#     ↓
# Azure Front Door (Global Network)
#     ├── Edge Location 1 (US East)
#     ├── Edge Location 2 (Europe)
#     └── Edge Location 3 (Asia)
#     ↓
# Origin Servers (Azure/On-Premises)
# ============================================================================

# ----------------------------------------------------------------------------
# Front Door Profile
# ----------------------------------------------------------------------------
# Front Door Profile is the top-level resource that contains all Front Door
# configurations including backend pools, routing rules, and frontend endpoints.
# ----------------------------------------------------------------------------
resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = var.front_door_name
  resource_group_name = var.resource_group_name
  sku_name            = "Premium_AzureFrontDoor"
  
  tags = var.tags
}

# ----------------------------------------------------------------------------
# Front Door
# ----------------------------------------------------------------------------
# Front Door (classic) resource - Note: Azure Front Door Standard/Premium
# uses different resources (azurerm_cdn_frontdoor_profile, etc.)
# This module uses the classic Front Door resource for compatibility.
# ----------------------------------------------------------------------------
resource "azurerm_frontdoor" "main" {
  name                                         = var.front_door_name
  location                                     = var.location
  resource_group_name                          = var.resource_group_name
  friendly_name                                = var.friendly_name != null ? var.friendly_name : var.front_door_name
  load_balancer_enabled                        = var.load_balancer_enabled
  
  # Backend Pools
  dynamic "backend_pool" {
    for_each = var.backend_pools
    content {
      name                = backend_pool.value.name
      health_probe_name   = backend_pool.value.health_probe_name
      load_balancing_name = backend_pool.value.load_balancing_name
      
      dynamic "backend" {
        for_each = backend_pool.value.backends
        content {
          host_header = backend.value.host_header
          address     = backend.value.address
          http_port   = backend.value.http_port
          https_port  = backend.value.https_port
          priority    = backend.value.priority
          weight      = backend.value.weight
          enabled     = backend.value.enabled
        }
      }
    }
  }
  
  # Backend Pool Health Probes
  dynamic "backend_pool_health_probe" {
    for_each = var.backend_pool_health_probes
    content {
      name                = backend_pool_health_probe.value.name
      protocol            = backend_pool_health_probe.value.protocol
      path                = backend_pool_health_probe.value.path
      interval_in_seconds = backend_pool_health_probe.value.interval_in_seconds
      enabled             = backend_pool_health_probe.value.enabled
    }
  }
  
  # Backend Pool Load Balancing Settings
  dynamic "backend_pool_load_balancing" {
    for_each = var.backend_pool_load_balancing
    content {
      name                            = backend_pool_load_balancing.value.name
      sample_size                     = backend_pool_load_balancing.value.sample_size
      successful_samples_required     = backend_pool_load_balancing.value.successful_samples_required
      additional_latency_milliseconds = backend_pool_load_balancing.value.additional_latency_milliseconds
    }
  }
  
  # Frontend Endpoints
  dynamic "frontend_endpoint" {
    for_each = var.frontend_endpoints
    content {
      name                                    = frontend_endpoint.value.name
      host_name                               = frontend_endpoint.value.host_name
      session_affinity_enabled                = frontend_endpoint.value.session_affinity_enabled
      session_affinity_ttl_seconds            = frontend_endpoint.value.session_affinity_ttl_seconds
      web_application_firewall_policy_link_id = frontend_endpoint.value.web_application_firewall_policy_link_id
    }
  }
  
  # Routing Rules
  dynamic "routing_rule" {
    for_each = var.routing_rules
    content {
      name               = routing_rule.value.name
      frontend_endpoints = routing_rule.value.frontend_endpoints
      accepted_protocols = routing_rule.value.accepted_protocols
      patterns_to_match  = routing_rule.value.patterns_to_match
      enabled            = routing_rule.value.enabled
      
      # Forwarding Configuration
      dynamic "forwarding_configuration" {
        for_each = routing_rule.value.route_configuration != null ? [routing_rule.value.route_configuration] : []
        content {
          forwarding_protocol                      = forwarding_configuration.value.forwarding_protocol
          backend_pool_name                        = forwarding_configuration.value.backend_pool_name
          cache_enabled                            = forwarding_configuration.value.cache_enabled
          cache_query_parameter_strip_directive    = forwarding_configuration.value.cache_query_parameter_strip_directive
          cache_duration                           = forwarding_configuration.value.cache_duration
          cache_use_dynamic_compression            = forwarding_configuration.value.compression_enabled
          query_parameter_strip_directive          = forwarding_configuration.value.query_parameter_strip_directive
          custom_forwarding_path                    = forwarding_configuration.value.forwarding_path
        }
      }
    }
  }
  
  tags = var.tags
}

