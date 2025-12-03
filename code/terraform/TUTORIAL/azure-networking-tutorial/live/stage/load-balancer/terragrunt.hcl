# ============================================================================
# TERRAGRUNT CONFIGURATION: Load Balancer (Stage Environment)
# ============================================================================
# This file configures the Azure Load Balancer module for the stage environment.
# It demonstrates dependency management - the Load Balancer depends on the VNet.
# ============================================================================

terraform {
  source = "../../../../modules//load-balancer"
}

include {
  path = find_in_parent_folders()
}

# ============================================================================
# DEPENDENCY BLOCK: Virtual Network Dependency
# ============================================================================
# The Load Balancer needs to be in the same VNet as the backend VMs.
# This dependency ensures the VNet is created before the Load Balancer.
# ============================================================================
dependency "vnet" {
  config_path = "../networking/vnet"

  # Mock outputs for when dependency is not yet applied
  # This allows terragrunt validate/plan to work without applying dependencies first
  mock_outputs = {
    vnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-networking-stage/providers/Microsoft.Network/virtualNetworks/vnet-stage"
    vnet_name         = "vnet-stage"
    subnet_ids        = {}
    subnet_names     = []
    network_security_group_ids = {}
  }

  # Skip outputs that might not exist yet
  skip_outputs = false
}

inputs = {
  resource_group_name = "rg-networking-stage"
  location           = "eastus"
  load_balancer_name = "lb-web-stage"

  # Load Balancer SKU: Standard for production features
  sku = "Standard"

  # Frontend IP configuration
  frontend_ip_configurations = [
    {
      name                 = "public-frontend"
      public_ip_address_id = null # Will be created separately or passed as dependency
      zones                = ["1", "2", "3"]
    }
  ]

  # Backend address pools
  backend_address_pools = [
    {
      name = "web-backend-pool"
    }
  ]

  # Health probes
  probe_configurations = [
    {
      name                = "http-probe"
      protocol            = "Http"
      port                = 80
      request_path        = "/health"
      interval_in_seconds = 5
      number_of_probes    = 2
    }
  ]

  # Load balancing rules
  load_balancing_rules = [
    {
      name                           = "http-rule"
      frontend_ip_configuration_name = "public-frontend"
      backend_address_pool_ids       = [] # Will be populated from backend_address_pools
      probe_id                       = null # Will be populated from probe_configurations
      protocol                       = "Tcp"
      frontend_port                  = 80
      backend_port                   = 80
      idle_timeout_in_minutes        = 4
      load_distribution              = "Default"
      enable_floating_ip             = false
      enable_tcp_reset               = false
    }
  ]

  # Tags
  tags = {
    Environment = "stage"
    Component   = "load-balancer"
  }
}

