# ============================================================================
# TERRAGRUNT CONFIGURATION: NAT Gateway (Stage Environment)
# ============================================================================
# This file configures the Azure NAT Gateway module for the stage environment.
# NAT Gateway provides outbound internet connectivity for subnets.
# ============================================================================

terraform {
  source = "../../../../modules//nat-gateway"
}

include {
  path = find_in_parent_folders()
}

dependency "vnet" {
  config_path = "../networking/vnet"

  mock_outputs = {
    vnet_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-networking-stage/providers/Microsoft.Network/virtualNetworks/vnet-stage"
    subnet_ids = {}
  }

  skip_outputs = false
}

inputs = {
  resource_group_name = "rg-networking-stage"
  location           = "eastus"
  nat_gateway_name   = "nat-gateway-stage"

  # NAT Gateway SKU: Standard (only option available)
  sku_name = "Standard"

  # Public IP configuration
  # NAT Gateway requires at least one public IP
  public_ip_address_ids = [] # Will be created separately or passed as dependency

  # Subnet associations
  # NAT Gateway can be associated with multiple subnets
  subnet_ids = [
    dependency.vnet.outputs.subnet_ids["app-subnet"],
    # Add more subnets as needed
  ]

  # Idle timeout in minutes (4-120, default 4)
  idle_timeout_in_minutes = 4

  # Tags
  tags = {
    Environment = "stage"
    Component   = "nat-gateway"
  }
}

