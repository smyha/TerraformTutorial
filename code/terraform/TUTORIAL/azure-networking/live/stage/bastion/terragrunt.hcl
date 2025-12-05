# ============================================================================
# TERRAGRUNT CONFIGURATION: Azure Bastion (Stage Environment)
# ============================================================================
# This file configures the Azure Bastion module for the stage environment.
# Azure Bastion provides secure RDP/SSH access to VMs without public IPs.
# ============================================================================

terraform {
  source = "../../../../modules//bastion"
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
  location          = "eastus"
  bastion_name      = "bastion-stage"

  # Bastion requires a dedicated subnet named "AzureBastionSubnet"
  # The subnet must have at least /26 CIDR and cannot have NSG or route table
  subnet_id = dependency.vnet.outputs.subnet_ids["bastion-subnet"] # Assuming bastion-subnet exists

  # Public IP configuration
  # Bastion requires a public IP in the same region
  public_ip_address_id = null # Will be created separately or passed as dependency

  # Bastion SKU: Basic or Standard
  sku = "Basic"

  # Scale units (only for Standard SKU)
  scale_units = null

  # Tags
  tags = {
    Environment = "stage"
    Component   = "bastion"
  }
}

